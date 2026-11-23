// O game revela as 36 figurinhas do álbum (pasta ../figurinhas).
window.FIGURINHAS_CONFIG = {
  total: 36,
  arquivos: Array.from({length:36},(_,i)=>`../../figurinhas/${String(i+1).padStart(2,'0')}.webp`)
};
