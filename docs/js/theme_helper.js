function enable()  {
    DarkReader.setFetchMethod(window.fetch)
    DarkReader.enable();
    localStorage.setItem('dark-mode', 'true');
  }
  
  function disable() {
    DarkReader.disable();
    localStorage.setItem('dark-mode', 'false');
  }
  
  function darkmode() {
    let enabled = localStorage.getItem('dark-mode')
  
    if (enabled === null) {
      if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
          enable();
      }
    } else if (enabled === 'true') {
      enable()
    }
  
    if (localStorage.getItem('dark-mode') === 'false') {
        enable();
    } else {
        disable();
    }
  }