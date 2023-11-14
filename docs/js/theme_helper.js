function ready(fn) {
  if (document.readyState !== 'loading') {
    fn();
    return;
  }
  document.addEventListener('DOMContentLoaded', fn);
}

ready(function(){
  let enabled = localStorage.getItem('dark-mode')
  let audio = document.createElement('audio');

  if (enabled === null) {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        enable();
    }
  } else if (enabled === 'true') {
    enable()
  }
});


function enable()  {
    DarkReader.setFetchMethod(window.fetch)
    DarkReader.enable();
    localStorage.setItem('dark-mode', 'true');
    document.getElementById('icon-dark').className = "fa fa-sun"
  }
  
  function disable() {
    DarkReader.disable();
    localStorage.setItem('dark-mode', 'false');
    document.getElementById('icon-dark').className = "fa fa-moon"
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