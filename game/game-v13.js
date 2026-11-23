(function(){
  const CFG={url:'',key:''}; // preencha com o mesmo Supabase do supabase-config.js para registrar as fases no painel
  const objetivos=[
    {titulo:'Fase 1 — Quem sou eu',texto:'Objetivo pedagógico: reconhecer interesses, talentos e valores como base do projeto de vida (BNCC, competências 6 e 8).'},
    {titulo:'Fase 2 — Sonhos e metas',texto:'Objetivo pedagógico: transformar sonhos em metas SMART, com curto, médio e longo prazo e plano B.'},
    {titulo:'Fase 3 — Explorando profissões',texto:'Objetivo pedagógico: conhecer áreas profissionais (saúde, educação, tecnologia, indústria, meio ambiente e economia criativa).'},
    {titulo:'Fase 4 — Caminhos da formação',texto:'Objetivo pedagógico: compreender itinerários, curso técnico, graduação, Enem, Sisu, cotas, ProUni, Fies e Pé-de-Meia.'},
    {titulo:'Fase final — Trabalho e projeto de vida',texto:'Objetivo pedagógico: conhecer os direitos do jovem trabalhador e colocar o projeto de vida em ação.'}
  ];
  function ciclo(){try{return JSON.parse(localStorage.getItem('cb_ciclo_v1')||'null')}catch(e){return null}}
  function device(){let id=localStorage.getItem('cb_device_id_v1');if(!id){id=crypto?.randomUUID?crypto.randomUUID():'00000000-0000-4000-8000-'+String(Date.now()).padStart(12,'0').slice(-12);localStorage.setItem('cb_device_id_v1',id)}return id}
  async function registrar(nome,resultado,recompensa){const c=ciclo();if(!c||!CFG.url||c.local)return;try{await fetch(`${CFG.url}/rest/v1/cb_atividades_resultados`,{method:'POST',headers:{apikey:CFG.key,'Content-Type':'application/json',Prefer:'return=minimal'},body:JSON.stringify({ciclo_id:c.id,device_id:device(),atividade:nome,categoria:'game',resultado,pontos:100,recompensa})})}catch(e){}}
  function cardDireitos(){
    let box=document.getElementById('dxGameDireitos');if(box)return;
    box=document.createElement('div');box.id='dxGameDireitos';box.style.cssText='position:fixed;inset:0;background:rgba(3,10,20,.92);z-index:100000;display:flex;align-items:center;justify-content:center;padding:18px';
    box.innerHTML=`<div style="max-width:720px;background:#fff;color:#122235;border-radius:22px;padding:28px;box-shadow:0 30px 70px #0008"><span style="font-weight:900;color:#166534">MISSÃO PEDAGÓGICA CONCLUÍDA</span><h2 style="font-size:2rem;margin:.4rem 0">Painel do Futuro — Projeto de Vida</h2><p>Você concluiu o game. Agora transforme o que aprendeu em atitude.</p><div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin:18px 0"><div style="padding:14px;background:#ecfdf5;border-radius:14px"><b>BNCC, competência 6</b><br><small>Trabalho e projeto de vida: entender o mundo do trabalho e fazer escolhas com autonomia e responsabilidade.</small></div><div style="padding:14px;background:#eff6ff;border-radius:14px"><b>Lei 14.945/2024</b><br><small>Ensino médio com 2.400 h de formação geral básica e 600 h de itinerários formativos.</small></div><div style="padding:14px;background:#fff7ed;border-radius:14px"><b>CF, art. 7º, XXXIII</b><br><small>Trabalho só a partir dos 16 anos, ou como aprendiz a partir dos 14 (CLT, art. 428).</small></div><div style="padding:14px;background:#f5f3ff;border-radius:14px"><b>Caminhos de acesso</b><br><small>Enem, Sisu, Lei de Cotas, ProUni, Fies, Pé-de-Meia e cursos técnicos.</small></div></div><p><b>Reflexão final:</b> qual é o primeiro passo do seu projeto de vida que você vai dar esta semana?</p><button style="border:0;border-radius:12px;padding:12px 18px;background:#166534;color:#fff;font-weight:800" onclick="document.getElementById('dxGameDireitos').remove();location.href='../index.html'">Voltar ao álbum</button></div>`;
    document.body.appendChild(box);
  }
  function atualizarObjetivo(){
    const fase=Number(document.getElementById('faseAtual')?.textContent||1)-1;
    const o=objetivos[Math.min(Math.max(fase,0),objetivos.length-1)];
    const t=document.getElementById('temaFase');if(t)t.innerHTML=`<b>${o.titulo}</b><br>${o.texto}`;
    const d=document.getElementById('descricaoFase');if(d)d.textContent='Conclua os objetivos do tabuleiro e relacione a vitória ao objetivo pedagógico desta fase.';
  }
  const obs=new MutationObserver(atualizarObjetivo);
  window.addEventListener('load',()=>{atualizarObjetivo();const f=document.getElementById('faseAtual');if(f)obs.observe(f,{childList:true,subtree:true,characterData:true})});
  const check=setInterval(()=>{
    if(typeof openModal!=='function')return;
    clearInterval(check);
    const antigo=window.openModal;
    window.openModal=function(title,text,options){
      const fase=document.getElementById('faseAtual')?.textContent||'?';
      const venceu=/vencida|missão concluída|conclu/i.test(String(title)+' '+String(text));
      if(venceu){registrar(`Game — fase ${fase}`,String(title),/pacote/i.test(String(text))?'pacote/figurinha':'recompensa do game');}
      const ret=antigo.apply(this,arguments);
      if(/missão concluída/i.test(String(title)))setTimeout(cardDireitos,350);
      return ret;
    };
  },100);
})();