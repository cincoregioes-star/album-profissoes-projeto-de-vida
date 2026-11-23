-- ============================================================
-- SUPABASE — ÁLBUM COMBATE AO BULLYING E AO CYBERBULLYING
-- Estrutura completa (tabelas, segurança e funções do painel).
--
-- Pode ser executado no MESMO projeto Supabase do Dupla Exclusão:
-- tudo usa o prefixo cb_ e não toca nas tabelas dupla_*.
--
-- Como usar: Supabase → SQL Editor → New query → cole este arquivo → Run.
-- Depois crie o login dos professores (veja o final do arquivo).
-- O script pode ser executado mais de uma vez sem apagar dados.
-- ============================================================

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

-- ------------------------------------------------------------
-- TABELAS
-- ------------------------------------------------------------
create table if not exists public.cb_ciclos (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  ativo boolean not null default true,
  pesquisa_final_liberada boolean not null default false,
  versao integer not null default 1,
  observacao text,
  encerrado_em timestamptz,
  created_at timestamptz not null default now()
);
create unique index if not exists cb_ciclos_um_ativo on public.cb_ciclos (ativo) where ativo;

create table if not exists public.cb_progresso (
  id uuid primary key default gen_random_uuid(),
  ciclo_id uuid references public.cb_ciclos(id) on delete set null,
  device_id text not null,
  nome text,
  escola_bairro text,
  turma text,
  figurinhas_coladas integer not null default 0 check (figurinhas_coladas between 0 and 36),
  pacotes integer not null default 0,
  repetidas integer not null default 0,
  simulados_concluidos integer not null default 0,
  ultimo_simulado text,
  ultimo_acertos integer,
  game_concluido boolean not null default false,
  album_completo boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists cb_progresso_device_idx on public.cb_progresso (device_id, created_at desc);

create table if not exists public.cb_simulados_resultados (
  id uuid primary key default gen_random_uuid(),
  ciclo_id uuid references public.cb_ciclos(id) on delete set null,
  device_id text,
  nome text,
  escola_bairro text,
  turma text,
  simulado text not null,
  acertos integer not null check (acertos between 0 and 10),
  total integer not null default 10,
  premio text,
  created_at timestamptz not null default now()
);
create index if not exists cb_simulados_created_idx on public.cb_simulados_resultados (created_at desc);

create table if not exists public.cb_concluintes (
  id uuid primary key default gen_random_uuid(),
  ciclo_id uuid references public.cb_ciclos(id) on delete set null,
  nome text not null,
  escola_bairro text,
  whatsapp text,
  codigo_confirmacao text not null unique,
  total_figurinhas integer not null default 36,
  album_completo boolean not null default true,
  premio_entregue boolean not null default false,
  device_id text,
  origem text default 'album-profissoes-projeto-de-vida',
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists cb_concluintes_created_idx on public.cb_concluintes (created_at asc);

create table if not exists public.cb_pesquisas_respostas (
  id uuid primary key default gen_random_uuid(),
  ciclo_id uuid references public.cb_ciclos(id) on delete set null,
  respondente_id text not null,
  tipo text not null check (tipo in ('inicial','final')),
  escola text,
  turma text,
  respostas jsonb not null default '{}'::jsonb,
  indicadores jsonb not null default '{}'::jsonb,
  metodologia jsonb not null default '{}'::jsonb,
  anonima boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists cb_pesquisas_ciclo_idx on public.cb_pesquisas_respostas (ciclo_id, tipo);

create table if not exists public.cb_atividades_resultados (
  id uuid primary key default gen_random_uuid(),
  ciclo_id uuid references public.cb_ciclos(id) on delete set null,
  device_id text,
  atividade text not null,
  categoria text,
  resultado text,
  pontos integer not null default 0,
  recompensa text,
  created_at timestamptz not null default now()
);
create index if not exists cb_atividades_ciclo_idx on public.cb_atividades_resultados (ciclo_id, created_at desc);

create table if not exists public.cb_professores (
  id uuid primary key default gen_random_uuid(),
  usuario text not null unique,
  nome text not null,
  perfil text not null default 'professor' check (perfil in ('professor','coordenacao','admin')),
  senha_hash text not null,
  ativo boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.cb_sessoes (
  token uuid primary key default gen_random_uuid(),
  professor_id uuid not null references public.cb_professores(id) on delete cascade,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

-- updated_at automático
create or replace function public.cb_set_updated_at()
returns trigger language plpgsql set search_path = public as $$
begin new.updated_at = now(); return new; end; $$;
drop trigger if exists trg_cb_concluintes_updated_at on public.cb_concluintes;
create trigger trg_cb_concluintes_updated_at before update on public.cb_concluintes
for each row execute function public.cb_set_updated_at();

-- ------------------------------------------------------------
-- SEGURANÇA (RLS)
-- Alunos (anon) só podem INSERIR dados e LER o ciclo.
-- A leitura dos dados é feita apenas pelas funções do painel,
-- que exigem login de professor.
-- ------------------------------------------------------------
alter table public.cb_ciclos enable row level security;
alter table public.cb_progresso enable row level security;
alter table public.cb_simulados_resultados enable row level security;
alter table public.cb_concluintes enable row level security;
alter table public.cb_pesquisas_respostas enable row level security;
alter table public.cb_atividades_resultados enable row level security;
alter table public.cb_professores enable row level security;
alter table public.cb_sessoes enable row level security;

drop policy if exists cb_ciclos_select on public.cb_ciclos;
create policy cb_ciclos_select on public.cb_ciclos for select to anon, authenticated using (true);

drop policy if exists cb_progresso_insert on public.cb_progresso;
create policy cb_progresso_insert on public.cb_progresso for insert to anon, authenticated
  with check (length(device_id) between 8 and 80);

drop policy if exists cb_simulados_insert on public.cb_simulados_resultados;
create policy cb_simulados_insert on public.cb_simulados_resultados for insert to anon, authenticated
  with check (total = 10);

drop policy if exists cb_concluintes_insert on public.cb_concluintes;
create policy cb_concluintes_insert on public.cb_concluintes for insert to anon, authenticated
  with check (total_figurinhas = 36 and album_completo = true and premio_entregue = false and length(nome) between 2 and 120);

drop policy if exists cb_pesquisas_insert on public.cb_pesquisas_respostas;
create policy cb_pesquisas_insert on public.cb_pesquisas_respostas for insert to anon, authenticated
  with check (anonima = true);

drop policy if exists cb_atividades_insert on public.cb_atividades_resultados;
create policy cb_atividades_insert on public.cb_atividades_resultados for insert to anon, authenticated
  with check (pontos between 0 and 1000);

grant select on public.cb_ciclos to anon, authenticated;
grant insert on public.cb_progresso, public.cb_simulados_resultados, public.cb_concluintes,
  public.cb_pesquisas_respostas, public.cb_atividades_resultados to anon, authenticated;
-- cb_professores e cb_sessoes: sem políticas = sem acesso direto.

-- ------------------------------------------------------------
-- FUNÇÕES DO PAINEL DOS PROFESSORES
-- ------------------------------------------------------------
create or replace function public.cb_professor_da_sessao(p_token text)
returns public.cb_professores
language plpgsql security definer set search_path = public, extensions as $$
declare v public.cb_professores;
begin
  if p_token is null or p_token !~ '^[0-9a-fA-F-]{36}$' then return null; end if;
  select p.* into v from public.cb_sessoes s join public.cb_professores p on p.id = s.professor_id
   where s.token = p_token::uuid and s.expires_at > now() and p.ativo;
  return v;
end; $$;

create or replace function public.cb_login_usuario(p_usuario text, p_senha text)
returns jsonb
language plpgsql security definer set search_path = public, extensions as $$
declare v public.cb_professores; v_token uuid; v_exp timestamptz;
begin
  select * into v from public.cb_professores
   where lower(usuario) = lower(trim(p_usuario)) and ativo;
  if v.id is null or v.senha_hash <> extensions.crypt(p_senha, v.senha_hash) then
    perform pg_sleep(0.4);
    return jsonb_build_object('ok', false, 'erro', 'Usuário ou senha inválidos.');
  end if;
  delete from public.cb_sessoes where expires_at < now();
  v_exp := now() + interval '12 hours';
  insert into public.cb_sessoes (professor_id, expires_at) values (v.id, v_exp) returning token into v_token;
  return jsonb_build_object('ok', true, 'token', v_token, 'usuario', v.usuario, 'nome', v.nome,
                            'perfil', v.perfil, 'expires_at', v_exp);
end; $$;

create or replace function public.cb_logout_usuario(p_token text)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  if p_token ~ '^[0-9a-fA-F-]{36}$' then delete from public.cb_sessoes where token = p_token::uuid; end if;
  return jsonb_build_object('ok', true);
end; $$;

create or replace function public.cb_painel_snapshot(p_token text)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v public.cb_professores;
begin
  v := public.cb_professor_da_sessao(p_token);
  if v.id is null then return jsonb_build_object('ok', false, 'erro', 'Sessão expirada. Entre novamente.'); end if;
  return jsonb_build_object(
    'ok', true, 'nome', v.nome, 'perfil', v.perfil,
    'progresso', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from (
        select distinct on (device_id) * from public.cb_progresso order by device_id, created_at desc) x), '[]'::jsonb),
    'simulados', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from (
        select * from public.cb_simulados_resultados order by created_at desc limit 3000) x), '[]'::jsonb),
    'concluintes', coalesce((select jsonb_agg(to_jsonb(x) - 'user_agent' order by x.created_at asc)
        from public.cb_concluintes x), '[]'::jsonb),
    'ciclos', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from public.cb_ciclos x), '[]'::jsonb),
    'pesquisas', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from public.cb_pesquisas_respostas x), '[]'::jsonb),
    'atividades', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from (
        select * from public.cb_atividades_resultados order by created_at desc limit 5000) x), '[]'::jsonb)
  );
end; $$;

create or replace function public.cb_painel_marcar_premio(p_token text, p_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v public.cb_professores;
begin
  v := public.cb_professor_da_sessao(p_token);
  if v.id is null then return jsonb_build_object('ok', false, 'erro', 'Sessão expirada.'); end if;
  update public.cb_concluintes set premio_entregue = true where id = p_id;
  if not found then return jsonb_build_object('ok', false, 'erro', 'Concluinte não encontrado.'); end if;
  return jsonb_build_object('ok', true);
end; $$;

create or replace function public.cb_painel_pesquisa_final(p_token text, p_ciclo_id uuid, p_liberada boolean)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v public.cb_professores;
begin
  v := public.cb_professor_da_sessao(p_token);
  if v.id is null then return jsonb_build_object('ok', false, 'erro', 'Sessão expirada.'); end if;
  update public.cb_ciclos set pesquisa_final_liberada = p_liberada where id = p_ciclo_id;
  if not found then return jsonb_build_object('ok', false, 'erro', 'Ciclo não encontrado.'); end if;
  return jsonb_build_object('ok', true);
end; $$;

create or replace function public.cb_painel_novo_ciclo(p_token text, p_nome text)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v public.cb_professores; v_id uuid;
begin
  v := public.cb_professor_da_sessao(p_token);
  if v.id is null then return jsonb_build_object('ok', false, 'erro', 'Sessão expirada.'); end if;
  if coalesce(trim(p_nome), '') = '' then return jsonb_build_object('ok', false, 'erro', 'Informe o nome do ciclo.'); end if;
  update public.cb_ciclos set ativo = false, encerrado_em = now() where ativo;
  insert into public.cb_ciclos (nome, ativo, pesquisa_final_liberada, observacao)
  values (trim(p_nome), true, false, 'Criado no painel por ' || v.usuario) returning id into v_id;
  return jsonb_build_object('ok', true, 'id', v_id);
end; $$;

-- Cadastro de professores: só pode ser usado aqui no SQL Editor.
create or replace function public.cb_criar_professor(p_usuario text, p_nome text, p_senha text, p_perfil text default 'professor')
returns text
language plpgsql security definer set search_path = public, extensions as $$
begin
  if length(coalesce(p_senha, '')) < 6 then raise exception 'A senha precisa ter pelo menos 6 caracteres.'; end if;
  insert into public.cb_professores (usuario, nome, perfil, senha_hash)
  values (lower(trim(p_usuario)), trim(p_nome), p_perfil, extensions.crypt(p_senha, extensions.gen_salt('bf')))
  on conflict (usuario) do update set nome = excluded.nome, perfil = excluded.perfil,
    senha_hash = excluded.senha_hash, ativo = true;
  return 'Professor ' || lower(trim(p_usuario)) || ' salvo.';
end; $$;

revoke all on function public.cb_professor_da_sessao(text) from public, anon, authenticated;
revoke all on function public.cb_criar_professor(text, text, text, text) from public, anon, authenticated;
revoke all on function public.cb_login_usuario(text, text) from public;
revoke all on function public.cb_logout_usuario(text) from public;
revoke all on function public.cb_painel_snapshot(text) from public;
revoke all on function public.cb_painel_marcar_premio(text, uuid) from public;
revoke all on function public.cb_painel_pesquisa_final(text, uuid, boolean) from public;
revoke all on function public.cb_painel_novo_ciclo(text, text) from public;
grant execute on function public.cb_login_usuario(text, text) to anon, authenticated;
grant execute on function public.cb_logout_usuario(text) to anon, authenticated;
grant execute on function public.cb_painel_snapshot(text) to anon, authenticated;
grant execute on function public.cb_painel_marcar_premio(text, uuid) to anon, authenticated;
grant execute on function public.cb_painel_pesquisa_final(text, uuid, boolean) to anon, authenticated;
grant execute on function public.cb_painel_novo_ciclo(text, text) to anon, authenticated;

-- ------------------------------------------------------------
-- PRIMEIRO CICLO (criado só se ainda não existir nenhum)
-- ------------------------------------------------------------
insert into public.cb_ciclos (nome, ativo, observacao)
select 'Ciclo 1 — Álbum Projeto de Vida', true, 'Ciclo inicial criado pelo script'
where not exists (select 1 from public.cb_ciclos);

-- ------------------------------------------------------------
-- CRIAR LOGIN DE PROFESSOR
-- Troque usuário, nome e senha e execute a linha abaixo (sem os dois traços).
-- Repita para cada professor. Rodar de novo com o mesmo usuário troca a senha.
-- ------------------------------------------------------------
-- select public.cb_criar_professor('carlos', 'Prof. Carlos André Tavares de Lima', 'TROQUE_ESTA_SENHA', 'admin');
