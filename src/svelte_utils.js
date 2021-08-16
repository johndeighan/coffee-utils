// Generated by CoffeeScript 2.5.1
// svelte_utils.coffee

// ---------------------------------------------------------------------------
//   svelteSourceCodeEsc - to display source code for a *.starbucks page
export var svelteSourceCodeEsc = function(str) {
  return str.replace(/\</g, '&lt;').replace(/\>/g, '&gt;').replace(/\{/g, '&lbrace;').replace(/\}/g, '&rbrace;').replace(/\$/g, '&dollar;');
};

// ---------------------------------------------------------------------------
//   svelteHtmlEsc - after converting markdown
export var svelteHtmlEsc = function(str) {
  return str.replace(/\{/g, '&lbrace;').replace(/\}/g, '&rbrace;').replace(/\$/g, '&dollar;');
};

// ---------------------------------------------------------------------------