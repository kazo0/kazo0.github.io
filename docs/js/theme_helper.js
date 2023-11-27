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
});
  
  function darkmode() {
    node1 = document.getElementById('theme_source');
    node2 = document.getElementById('theme_source_dark');
    if (node1.getAttribute('rel') == 'stylesheet') {
      node1.setAttribute('rel', 'stylesheet alternate');
      node2.setAttribute('rel', 'stylesheet');
      sessionStorage.setItem('theme', 'dark');
    } else {
      node2.setAttribute('rel', 'stylesheet alternate');
      node1.setAttribute('rel', 'stylesheet');
      sessionStorage.setItem('theme', 'light');
    }
    return false;
    }