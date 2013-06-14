var textarea    = document.getElementsByName('document[source]')[0],
    preview     = document.getElementById('preview'),
    previewLink = document.getElementById('preview-link'),
    pos         = textarea.value.length * 2,
    dirty       = true

textarea.focus()
textarea.setSelectionRange(pos, pos)
textarea.addEventListener('keyup', function(ev) {
  dirty = true
}, false)

updatePreview = function() {
  if (!dirty) return;
  var xhr = new XMLHttpRequest()
  xhr.onreadystatechange = function() {
    if (xhr.readyState == 4 && xhr.status == 200) {
      preview.innerHTML = xhr.responseText
      dirty = false
    }
  }
  xhr.open('POST', '/render', true)
  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
  xhr.send('source=' + encodeURIComponent(textarea.value))
}

togglePreview = function() {
  if (window.location.hash == '#preview') {
    window.location.hash = ''
    previewLink.textContent = 'P'
    previewLink.setAttribute('title', 'Preview changes (Alt-P)')
  } else {
    window.location.hash = '#preview'
    previewLink.textContent = 'E'
    previewLink.setAttribute('title', 'Edit document (Alt-P)')
  }
}

window.setTimeout(function() {
  updatePreview()
  window.setTimeout(arguments.callee, 1000)
}, 0)

previewLink.addEventListener('click', function(ev) {
  togglePreview()
  ev.preventDefault()
})

keymage('alt-p', togglePreview)

var saveButton = document.querySelector('a[href="#save"]')
saveButton.addEventListener('click', function(ev) {
  document.forms[0].submit()
  ev.preventDefault()
}, false)
