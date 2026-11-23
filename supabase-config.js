// ============================================================
// COMBATE AO BULLYING — SUPABASE / BOOTSTRAP
// Tabelas e funções próprias (prefixo cb_).
// Para criar a estrutura, rode supabase/COMBATE_BULLYING_SUPABASE.sql no SQL Editor.
// ============================================================
window.SUPABASE_CONFIG = {
  // MODO LIVRE: enabled=false. O álbum funciona por completo e salva tudo no próprio aparelho.
  // Para ter o painel dos professores, crie um projeto no Supabase, rode
  // supabase/COMBATE_BULLYING_SUPABASE.sql, preencha url/chave abaixo e mude enabled para true.
  enabled: false,
  url: "",
  publishableKey: "",
  anonKey: "",
  table: "cb_concluintes",
  premiosDisponiveis: 10,
  totalFigurinhas: 36,
  projeto: "Álbum Profissões e Projeto de Vida",
  versao: 1
};

(function(){
  const CFG=window.SUPABASE_CONFIG;
  const DEVICE_KEY='cb_device_id_v1';
  const PROFILE_KEY='cb_aluno_perfil_v1';
  const QUEUE_KEY='cb_sync_queue_v1';
  let flushing=false;

  function deviceId(){
    let id=localStorage.getItem(DEVICE_KEY);
    if(!id){id=(window.crypto&&crypto.randomUUID?crypto.randomUUID():'00000000-0000-4000-8000-'+String(Date.now()).padStart(12,'0').slice(-12));localStorage.setItem(DEVICE_KEY,id)}
    return id;
  }
  function perfil(){try{return JSON.parse(localStorage.getItem(PROFILE_KEY)||'{}')}catch(e){return {}}}
  function salvarPerfil(p){const a=perfil();const n={nome:String(p.nome||a.nome||'').trim().slice(0,120),escola_bairro:String(p.escola_bairro||a.escola_bairro||'').trim().slice(0,160),turma:String(p.turma||a.turma||'').trim().slice(0,80)};localStorage.setItem(PROFILE_KEY,JSON.stringify(n));return n}
  function fila(){try{return JSON.parse(localStorage.getItem(QUEUE_KEY)||'[]')}catch(e){return []}}
  function setFila(v){localStorage.setItem(QUEUE_KEY,JSON.stringify(v.slice(-400)))}
  function enfileirar(table,payload){const q=fila();q.push({table,payload});setFila(q);flush()}
  async function post(table,payload){const r=await fetch(`${CFG.url}/rest/v1/${table}`,{method:'POST',headers:{apikey:CFG.publishableKey,'Content-Type':'application/json',Prefer:'return=minimal'},body:JSON.stringify(payload)});if(!r.ok)throw new Error(await r.text())}
  async function flush(){if(flushing||!navigator.onLine)return;flushing=true;try{let q=fila();while(q.length){try{await post(q[0].table,q[0].payload);q.shift();setFila(q)}catch(e){break}}}finally{flushing=false}}

  function abrirIdentificacao(){
    if(typeof modal!=='function')return;
    modal(`<div class="ficha-detalhada"><button class="ficha-fechar-x" onclick="fecharModal()">×</button><h2>Identificação do aluno 🔒</h2><p>Esta área será habilitada após a definição do projeto.</p><p>Enquanto isso, você pode usar normalmente o álbum, os simulados, o game, os vídeos e as missões. Seu progresso fica salvo neste aparelho.</p><div class="ficha-acoes"><button class="ficha-fechar-btn" onclick="fecharModal()">Entendi</button></div></div>`);
  }
  window.dxSalvarIdentificacao=function(){const nome=document.getElementById('dxNome')?.value.trim()||'';if(nome.length<2)return alert('Digite o nome do aluno.');salvarPerfil({nome,escola_bairro:document.getElementById('dxEscola')?.value||'',turma:document.getElementById('dxTurma')?.value||''});if(typeof fecharModal==='function')fecharModal()};

  function substituirConclusao(){
    window.telaConclusao=function(){
      const codigo=estado.codigoConfirmacao||('CB-'+Date.now().toString().slice(-6));estado.codigoConfirmacao=codigo;if(typeof salvar==='function')salvar();const p=perfil();
      modal(`<div class="conclusao"><h2>Parabéns!</h2><p>Você completou o Álbum Digital Profissões e Projeto de Vida.</p><p><b>Código de confirmação:</b> ${codigo}</p><p>A ordem de conclusão é conferida exclusivamente pela equipe pedagógica.</p></div><div class="form-final"><input id="nomeFinal" placeholder="Nome do participante" value="${String(p.nome||'').replace(/"/g,'&quot;')}"><input id="escolaFinal" placeholder="Escola" value="${String(p.escola_bairro||'').replace(/"/g,'&quot;')}"><input id="turmaFinal" placeholder="Turma / série" value="${String(p.turma||'').replace(/"/g,'&quot;')}"></div><button class="btn" onclick="registrarConclusao()">Registrar conclusão</button>`);
    };
    window.registrarConclusao=function(){
      const nome=document.getElementById('nomeFinal')?.value.trim()||'',escola=document.getElementById('escolaFinal')?.value.trim()||'',turma=document.getElementById('turmaFinal')?.value.trim()||'';if(nome.length<2)return alert('Digite o nome.');salvarPerfil({nome,escola_bairro:escola,turma});
      let ciclo=null;try{ciclo=JSON.parse(localStorage.getItem('cb_ciclo_v1')||'null')}catch(e){}
      const item={ciclo_id:ciclo?.id||null,nome,escola_bairro:[escola,turma].filter(Boolean).join(' • '),codigo_confirmacao:estado.codigoConfirmacao,total_figurinhas:36,album_completo:true,premio_entregue:false,device_id:deviceId(),origem:'album-profissoes-projeto-de-vida-v1'};
      enfileirar('cb_concluintes',item);estado.conclusaoRegistrada=true;if(typeof salvar==='function')salvar();modal(`<div class="conclusao"><h2>Conclusão registrada</h2><p><b>Código:</b> ${item.codigo_confirmacao}</p><p>${navigator.onLine?'Sincronização iniciada.':'Registro salvo offline e será sincronizado quando a internet voltar.'}</p></div><button class="btn" onclick="fecharModal()">Fechar</button>`);
    };
  }

  function instalarBase(){
    deviceId();
    const nav=document.querySelector('.topo nav');
    if(nav&&!document.getElementById('dxBtnPerfil')){const b=document.createElement('button');b.id='dxBtnPerfil';b.textContent='Identificar aluno 🔒';b.onclick=abrirIdentificacao;nav.appendChild(b)}
    substituirConclusao();flush();
  }

  function carregarScript(src,id){if(document.getElementById(id))return;const s=document.createElement('script');s.src=src;s.id=id;s.defer=true;document.body.appendChild(s)}
  function carregarCss(href,id){if(document.getElementById(id))return;const l=document.createElement('link');l.rel='stylesheet';l.href=href;l.id=id;document.head.appendChild(l)}

  window.addEventListener('online',flush);
  window.addEventListener('load',function(){
    const path=location.pathname.toLowerCase();
    if(CFG.enabled&&(path.endsWith('/professor.html')||path.endsWith('professor.html'))){
      carregarScript('professor-ui-v23.js','dxProfessorUiV23');
      return;
    }
    carregarCss('ux-mobile-fix-v20.css','dxUxV20Css');
    carregarCss('student-ui-v22.css','dxStudentV23Css');
    instalarBase();
    carregarScript('simulados-v13.js','dxSimuladosV13');
    carregarScript('jornada-cb.js','cbJornada');
    carregarScript('ux-mobile-fix-v20.js','dxUxV20Js');
    carregarScript('student-ui-v22.js','dxStudentV23Js');
  });
})();