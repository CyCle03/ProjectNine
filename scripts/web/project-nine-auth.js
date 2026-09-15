(() => {
  const auth = 'https://auth.elcherlab.com';
  const box = document.createElement('aside');
  box.style.cssText = 'position:fixed;z-index:20;right:12px;top:12px;max-width:calc(100vw - 24px);padding:10px 12px;border-radius:12px;background:#172335ee;color:#fff;font:15px system-ui,sans-serif;box-shadow:0 4px 18px #0008';
  document.body.appendChild(box);

  const api = async (path, options = {}) => {
    const response = await fetch(auth + path, { credentials: 'include', headers: { 'Content-Type': 'application/json' }, ...options });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.error || '요청에 실패했습니다.');
    return data;
  };

  const home = (user, error = '') => {
    box.replaceChildren();
    if (user) {
      const name = document.createElement('strong');
      name.textContent = user.username;
      const logout = document.createElement('button');
      logout.textContent = '로그아웃';
      box.append(name, document.createTextNode(' 로그인됨 '), logout);
      logout.onclick = async () => { await api('/api/logout', { method: 'POST', body: '{}' }); location.reload(); };
      return;
    }
    const login = document.createElement('button');
    login.textContent = '로그인 / 가입';
    box.appendChild(login);
    if (error) {
      const message = document.createElement('div');
      message.style.cssText = 'margin-top:8px;color:#ffb4ab';
      message.textContent = error;
      box.appendChild(message);
    }
    login.onclick = form;
  };

  const form = () => {
    box.innerHTML = '<form style="display:grid;gap:8px"><label>아이디 <input name="username" required autocomplete="username"></label><label>비밀번호 <input name="password" type="password" required autocomplete="current-password"></label><label><input name="ageConfirm" type="checkbox"> 만 14세 이상입니다</label><button>로그인</button><button type="button" data-signup>가입</button><button type="button" data-close>닫기</button></form>';
    const f = box.querySelector('form');
    const submit = async (signup) => {
      const values = Object.fromEntries(new FormData(f));
      if (signup && !values.ageConfirm) { home(null, '가입하려면 만 14세 이상 확인이 필요합니다.'); return; }
      values.ageConfirm = Boolean(values.ageConfirm);
      try {
        await api(signup ? '/api/signup' : '/api/login', { method: 'POST', body: JSON.stringify(values) });
        location.reload();
      } catch (error) {
        home(null, error.message);
      }
    };
    f.onsubmit = (event) => { event.preventDefault(); submit(false); };
    f.querySelector('[data-signup]').onclick = () => submit(true);
    f.querySelector('[data-close]').onclick = () => home();
  };

  api('/api/me').then((data) => home(data.user)).catch(() => home(null, '로그인 서버 연결 실패'));
})();
