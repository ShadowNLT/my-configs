
/* =================================================================== MODEL
   One bottleneck link: exactly one response packet is delivered per tick,
   shared round-robin by every job with bytes ready. Handshakes and requests
   cost lane time but no link time. Every number on screen comes from here. */
const TICK_MS=20, RTT=2, TW=64, RECOVER=4;
const ASSETS=[
  {name:'index.html',wait:2,packets:2},{name:'style.css',wait:1,packets:2},
  {name:'hero.jpg',  wait:3,packets:8},{name:'app.js',   wait:1,packets:3},
  {name:'logo.png',  wait:1,packets:2},{name:'api.json', wait:2,packets:2},
  {name:'font.woff2',wait:1,packets:3}];

function J(a,lane,hs,prereq,after){return{a,lane,hs:hs||0,prereq:prereq||null,after:after||null,
  discovered:0,start:null,req_t:null,ready:null,left:a.packets,done:null};}

function simulate(jobs,loss){
  jobs.forEach(j=>{j.start=null;j.req_t=null;j.ready=null;j.left=j.a.packets;j.done=null;});
  const lanes={},wire=new Array(TW).fill(null);
  jobs.forEach(j=>{if(!lanes[j.lane])lanes[j.lane]=new Array(TW).fill(null);});
  const put=(c,s,n,k)=>{for(let i=Math.max(0,s);i<Math.min(s+n,TW);i++)c[i]={k};};
  let rr=0,stallEnd=0,fired=false,held=[],lostAt=-1,rtxAt=-1;
  for(let t=0;t<TW;t++){
    for(const j of jobs){
      if(j.start!==null)continue;
      let disc=j.discovered;
      if(j.after){ if(j.after.done===null)continue; disc=Math.max(disc,j.after.done); }
      if(t<disc)continue;
      if(j.prereq&&(j.prereq.done===null||j.prereq.done>t))continue;
      j.start=t; j.req_t=t+j.hs; j.ready=j.req_t+1+j.a.wait;
      const c=lanes[j.lane];
      put(c,t,j.hs,'hs'); put(c,j.req_t,1,'req'); put(c,j.req_t+1,j.a.wait,'wait');
    }
    for(const j of jobs){
      let disc=j.discovered;
      if(j.after){ if(j.after.done===null)continue; disc=Math.max(disc,j.after.done); }
      if(disc<=t&&(j.start===null||t<j.start)&&lanes[j.lane][t]===null)
        lanes[j.lane][t]={k:'block'};
    }
    if(held.length&&t===stallEnd){
      wire[t]={k:'rtx'}; rtxAt=t;
      for(const j of held){ j.left--; if(j.left===0)j.done=t; lanes[j.lane][t]={k:'burst',lane:j.lane}; }
      held=[];
      for(const j of jobs) if(j.left>0&&j.ready!==null&&j.ready<=t&&lanes[j.lane][t]===null)
        lanes[j.lane][t]={k:'wait'};
      continue;
    }
    const stalling=t<stallEnd;
    const frozenLane=(stalling&&loss&&loss.stream!=null)?loss.stream:-1;
    const frozenAll=stalling&&frozenLane<0;
    let pick=-1;
    for(let k=0;k<jobs.length;k++){
      const i=(rr+k)%jobs.length, j=jobs[i];
      if(j.left>0&&j.ready!==null&&j.ready<=t){
        if(frozenLane>=0&&j.lane===frozenLane)continue;
        pick=i;break;
      }
    }
    for(const j of jobs)
      if(j.left>0&&j.ready!==null&&j.ready<=t&&lanes[j.lane][t]===null)
        lanes[j.lane][t]={k:(stalling&&(frozenAll||j.lane===frozenLane))?'stall':'wait'};
    if(pick<0)continue;
    rr=pick+1; const j=jobs[pick];
    if(loss&&!fired&&t>=loss.tick&&(loss.stream==null||j.lane===loss.stream)){
      wire[t]={k:'lost'}; stallEnd=t+RECOVER; fired=true; lostAt=t; continue;
    }
    if(stalling&&(frozenAll||j.lane===frozenLane)){
      wire[t]={k:'held',lane:j.lane}; held.push(j); lanes[j.lane][t]={k:'stall'};
    }else{
      wire[t]={k:'pkt',lane:j.lane}; lanes[j.lane][t]={k:'resp',lane:j.lane};
      j.left--; if(j.left===0)j.done=t+1;
    }
  }
  const fin=Math.max(...jobs.filter(j=>j.done!==null).map(j=>j.done),0)||TW;
  return {lanes,wire,fin,lostAt,rtxAt};
}

/* =============================================================== SCENES
   anno kinds:  point {lane,tick,text,dir}      arrow onto one cell
                span  {lane,from,to,text,live}  measured bracket under a lane
                band  {from,to,text}            vertical region across all lanes  */
function h10(){
  const jobs=ASSETS.map((a,i)=>J(a,i,RTT));
  for(let i=1;i<jobs.length;i++){jobs[i].prereq=jobs[i-1];jobs[i].after=jobs[0];}
  const r=simulate(jobs);
  return{proto:'HTTP/1.0',title:'A fresh connection for <em>every single file</em>',
    sub:'One row per asset. Open a connection, fetch one thing, close it, start over.',
    lanes:ASSETS.map((a,i)=>[a.name,r.lanes[i]]),fin:r.fin,jobs,
    anno:[
      {at:2,kind:'point',lane:0,tick:0,dir:'up',text:'a whole round trip before it can even ask',color:'--hs'},
      {at:jobs[2].start,kind:'span',lane:2,from:jobs[0].done,to:jobs[2].start,live:true,
       text:'hero.jpg waiting its turn',color:'--block'},
      {at:jobs[4].start-3,kind:'point',lane:4,tick:jobs[4].start,dir:'down',
       text:'handshake #5 — nothing here is reused',color:'--hs'},
      {at:jobs[6].start,kind:'span',lane:6,from:jobs[0].done,to:jobs[6].start,live:true,
       text:'font.woff2 blocked',color:'--block'}],
    notes:[[1,'Each row is one asset, and each gets its own connection.'],
      [8,'HTTP/1.0 closes that connection after the response, so the next asset starts from zero — a fresh handshake, a fresh round trip.'],
      [26,'Seven assets, seven handshakes, nothing overlapping. The hatched red is time an asset is known about but not yet allowed to begin.',1]]};
}
function h11(){
  const jobs=ASSETS.map((a,i)=>J(a,i,i===0?RTT:0));
  for(let i=1;i<jobs.length;i++){jobs[i].prereq=jobs[i-1];jobs[i].after=jobs[0];}
  const r=simulate(jobs);
  const hero=jobs[2],font=jobs[6];
  return{proto:'HTTP/1.1 keep-alive',title:'One connection, reused — and <em>strictly in order</em>',
    sub:'The handshake is paid once. But a connection carries exactly one request at a time.',
    lanes:ASSETS.map((a,i)=>[a.name,r.lanes[i]]),fin:r.fin,jobs,
    anno:[
      {at:1,kind:'point',lane:0,tick:0,dir:'up',text:'handshake — paid once, then kept open',color:'--req'},
      {at:hero.start+1,kind:'point',lane:2,tick:hero.req_t+1,dir:'up',
       text:'server still generating hero.jpg',color:'--wait2'},
      {at:hero.start,kind:'band',from:hero.start,to:hero.done,live:true,
       text:'the connection is busy — nobody else may speak',color:'--block'},
      {at:jobs[0].done+1,kind:'span',lane:6,from:jobs[0].done,to:font.start,live:true,
       text:'font.woff2 blocked',color:'--block'},
      {at:font.start,kind:'point',lane:6,tick:font.req_t,dir:'down',
       text:'…finally allowed to ask',color:'--req'}],
    notes:[[2,'The connection stays open now, so the handshake is paid once. Better.'],
      [11,'But hero.jpg is slow to generate, and one connection carries one request at a time…'],
      [15,'…so every hatched bar below it is a request the client is not allowed to send yet.',1],
      [24,'That is head-of-line blocking: the whole line moves at the pace of its slowest member.',1],
      [33,'Pipelining let you send ahead, but responses still had to come back in order — and proxies mangled it, so browsers shipped with it off.']]};
}
function par(){
  const idx=J(ASSETS[0],0,RTT), st=J(ASSETS[1],0,0,idx,idx);
  const jobs=[idx,st].concat(ASSETS.slice(2).map((a,k)=>J(a,k+1,RTT,null,idx)));
  const r=simulate(jobs);
  return{proto:'HTTP/1.1 × 6',title:'The workaround: <em>just open more connections</em>',
    sub:'Chrome and Firefox open up to six TCP connections per origin. Each row is a connection.',
    lanes:[0,1,2,3,4,5].map(i=>['conn '+(i+1),r.lanes[i]]),fin:r.fin,drain:true,jobs,
    anno:[
      {at:idx.done,kind:'band',from:idx.done,to:idx.done+RTT,
       text:'six handshakes at once',color:'--hs'},
      {at:idx.done+RTT+2,kind:'point',lane:1,tick:jobs[2].ready+1,dir:'up',
       text:'hero.jpg is still slowest — but now it only blocks its own line',color:'--s2'},
      {at:idx.done+4,kind:'span',lane:5,from:idx.done+RTT,to:r.fin,
       text:'six connections, one shared link — no extra bandwidth',color:'--faint'}],
    notes:[[2,'Six lines instead of one, so a slow asset only holds up its own connection.'],
      [10,'But that is six handshakes, and the six share one bottleneck link — nobody actually gained bandwidth.'],
      [16,'And the cap bites. On a real page, everything past the sixth asset queues for a free connection.',1]]};
}
function muxJobs(){
  const idx=J(ASSETS[0],0,RTT);
  return [idx].concat(ASSETS.slice(1).map((a,k)=>J(a,k+1,0,null,idx)));
}
function h2(loss){
  const jobs=muxJobs(), r=simulate(jobs,loss);
  return{proto:'HTTP/2',title:'Seven streams on one connection — <em>until a packet drops</em>',
    sub:'The bottom row is the single TCP connection, coloured by which stream each packet carries.',
    lanes:ASSETS.map((a,i)=>[a.name,r.lanes[i]]),wire:['TCP wire',r.wire],fin:r.fin,jobs,
    anno:[
      {at:jobs[1].req_t,kind:'point',lane:1,tick:jobs[1].req_t,dir:'up',
       text:'all seven requests go out at once',color:'--req'},
      {at:r.lostAt,until:r.rtxAt,kind:'point',wire:true,tick:r.lostAt,dir:'down',
       text:'one packet dropped',color:'--lost'},
      {at:r.lostAt+1,kind:'band',from:r.lostAt,to:r.rtxAt,live:true,
       text:'every stream stalls — TCP delivers in order or not at all',color:'--stall'},
      {at:r.rtxAt,kind:'point',wire:true,tick:r.rtxAt,dir:'down',
       text:'retransmit lands — everything releases at once',color:'--rtx'}],
    notes:[[7,'All seven requests go out together and the responses interleave. That is multiplexing.'],
      [11,'No HTTP-level head-of-line blocking any more: hero.jpg holds up nobody.'],
      [r.lostAt+1,'✗ — one packet is lost, and TCP is a single ordered byte stream.',1],
      [r.lostAt+2,'The bytes keep arriving, but the kernel may not hand any of them up out of order — so all seven stall at once.',1],
      [r.rtxAt+2,'Head-of-line blocking is back, one layer down, in the transport.']]};
}
function h3(loss){
  const jobs=muxJobs(), r=simulate(jobs,loss);
  return{proto:'HTTP/3 over QUIC',title:'Same loss — but the streams are <em>independent</em>',
    sub:'QUIC runs on UDP and orders bytes per stream, not per connection.',
    lanes:ASSETS.map((a,i)=>[a.name,r.lanes[i]]),wire:['UDP wire',r.wire],fin:r.fin,jobs,
    anno:[
      {at:r.lostAt,kind:'point',wire:true,tick:r.lostAt,dir:'down',
       text:'the identical loss, same moment',color:'--lost'},
      {at:r.lostAt+1,kind:'span',lane:2,from:r.lostAt,to:r.lostAt+RECOVER,
       text:'only hero.jpg waits',color:'--stall'},
      {at:r.lostAt+2,kind:'point',lane:4,tick:r.lostAt+2,dir:'down',
       text:'the other six keep being delivered',color:'--ok'}],
    notes:[[7,'Same seven streams, same shared link, same bottleneck.'],
      [r.lostAt+1,'✗ — the identical loss, this time on hero.jpg.'],
      [r.lostAt+3,'Only that one row stalls. Every other stream is delivered untouched, because nothing else was waiting on those bytes to be in order.',1],
      [r.lostAt+9,'QUIC also folds TLS into the transport handshake: one round trip, or zero when resuming.']]};
}

const probe=muxJobs(), clean=simulate(probe), LT=probe[0].done+3;
const S=[h10(),h11(),par(),h2({tick:LT,stream:null}),h3({tick:LT,stream:2})];
S.push({proto:'Summary',title:'What each change actually bought',
  sub:'Time until the last byte reaches the page. Derived from the model above, not measured.',
  summary:[['HTTP/1.0','connection per request',S[0].fin,'--block'],
    ['HTTP/1.1','keep-alive, one line',S[1].fin,'#ef8354'],
    ['HTTP/1.1','six parallel connections',S[2].fin,'--rtx'],
    ['HTTP/2','multiplexed, no loss',clean.fin,'--s1'],
    ['HTTP/2','multiplexed, one loss',S[3].fin,'--s1'],
    ['HTTP/3','QUIC, the same loss',S[4].fin,'--s0']],
  takeaways:[['keep-alive','stopped paying a handshake per file'],
    ['6 connections','bought parallelism, at six times the setup and no extra bandwidth'],
    ['HTTP/2','many streams on one connection — no head-of-line blocking in HTTP'],
    ['HTTP/3 / QUIC','independent streams — none left in the transport either'],
    ['but note','under packet loss HTTP/2 can trail six HTTP/1.1 connections. That is precisely why QUIC was worth building.',1]],
  fin:54,notes:[],anno:[]});


/* ===================================================== presentation config
   These used to be hardcoded inside the player. They belong to the topic. */
const LABELS = { hs:'connecting', req:'requesting', wait:'server thinking',
                 resp:'receiving', block:'queued', stall:'stalled',
                 wire:'carrying', idle:'idle' };
const LEG = [['--hs','handshake'],['--req','request'],['--wait','server thinking']];
const LEG_PLAIN = LEG.concat([['--s1','bytes arriving'],['--block','blocked in the queue']]);
const LEG_WIRE  = LEG.concat([['--s0','bytes arriving'],['--block','blocked in the queue'],
                              ['--stall','stalled by loss'],['--lost','packet lost'],
                              ['--rtx','retransmit']]);
const STATS = [
  { label:'ms elapsed',       kind:'elapsed' },
  { label:'ms blocked',       kind:'sum',  of:['block','stall'],  tone:'bad'  },
  { label:'assets delivered', kind:'done', of:['resp','burst'],   tone:'good' }];

S.forEach(s => {
  s.tag = s.proto;
  if (!s.summary) s.legend = s.wire ? LEG_WIRE : LEG_PLAIN;
  if (s.wire) s.statLabels = [null, 'ms stalled', null];
});
S[2].drain = { total:30, per:6, everyTicks:4,
               label:'a real page: 30 assets, six at a time' };
S[5].foot  = 'Model, not measurement — 40 ms round trip, one shared bottleneck link at one '
           + 'packet per tick, seven assets, one lost packet in every run marked "one loss".';

/* --- matched-condition comparison -------------------------------------
   The original charted a LOSS-FREE six-connection run against a WITH-LOSS
   HTTP/2 run and concluded HTTP/2 trails. Run matched, they tie — so the
   comparison is rebuilt here and the claim is retired. */
(function () {
  const parJobs = () => { const idx=J(ASSETS[0],0,RTT), st=J(ASSETS[1],0,0,idx,idx);
    return [idx,st].concat(ASSETS.slice(2).map((a,k)=>J(a,k+1,RTT,null,idx))); };
  const parLoss = simulate(parJobs(), {tick:LT, stream:null});
  S[5].summary = [
    ['HTTP/1.0','connection per request',       S[0].fin,   '--block'],
    ['HTTP/1.1','keep-alive, one line',         S[1].fin,   '#ef8354'],
    ['HTTP/1.1','six connections, no loss',     S[2].fin,   '--rtx'],
    ['HTTP/2',  'multiplexed, no loss',         clean.fin,  '--s1'],
    ['HTTP/1.1','six connections, one loss',    parLoss.fin,'--rtx'],
    ['HTTP/2',  'multiplexed, one loss',        S[3].fin,   '--s1'],
    ['HTTP/3',  'QUIC, the same loss',          S[4].fin,   '--s0']];
  S[5].takeaways = [
    ['keep-alive',   'stopped paying a handshake per file'],
    ['6 connections','parallelism, at six times the setup and no extra bandwidth'],
    ['HTTP/2',       'many streams on one connection — no head-of-line blocking in HTTP'],
    ['HTTP/3',       'independent streams — none left in the transport either'],
    ['read this',    'under loss these finish within one tick of each other. At 20 ms per '
                   + 'tick this model cannot resolve the difference, so it is not evidence '
                   + 'either way — the real distinction is why QUIC exists, and this '
                   + 'artefact does not demonstrate it.', 1]];
})();
