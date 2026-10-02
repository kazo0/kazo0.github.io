function ready(fn) {
  if (document.readyState !== 'loading') {
    fn();
    return;
  }
  document.addEventListener('DOMContentLoaded', fn);
}

ready(function(){
  document.getElementById('theme-toggle').onclick = function() {
    darkmode()
  }
  let theme = localStorage.getItem('theme')

  if (theme === null) {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        enable();
    }
  } else if (theme === "dark") {
    enable()
  }

  if (localStorage.getItem('theme') === "light") {
    disable();
  } else {
      enable();
  }
});
  
  function enable()  {
    localStorage.setItem('theme', 'dark');
    document.getElementById('icon-dark').className = "fa fa-sun"
    node1 = document.getElementById('theme_source');
    node2 = document.getElementById('theme_source_dark');
    node1.setAttribute('rel', 'stylesheet alternate'); 
    node2.setAttribute('rel', 'stylesheet');
  }

  function disable() {
    node1 = document.getElementById('theme_source');
    node2 = document.getElementById('theme_source_dark');
    node2.setAttribute('rel', 'stylesheet alternate');
    node1.setAttribute('rel', 'stylesheet');
    localStorage.setItem('theme', 'light');
    document.getElementById('icon-dark').className = "fa fa-moon"
  }

  function darkmode() {
    let theme = localStorage.getItem('theme')

    if (theme === null) {
      if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
          enable();
      }
    } else if (theme === "dark") {
      enable()
    }

    if (localStorage.getItem('theme') === "light") {
        enable();
    } else {
        disable();
    }
  }