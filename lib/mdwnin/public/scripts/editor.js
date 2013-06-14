var textarea    = document.getElementsByName('document[source]')[0],
    preview     = document.getElementById('preview'),
    previewLink = document.getElementById('preview-link'),
    saveButton  = document.querySelector('a[href="#save"]'),
    pos         = textarea.value.length * 2,
    dirty       = true

textarea.focus()
textarea.setSelectionRange(pos, pos)

// Preview-related function

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
    textarea.focus()
  } else {
    window.location.hash = '#preview'
    previewLink.textContent = 'E'
    previewLink.setAttribute('title', 'Edit document (Alt-P)')
  }
}

scrollPreview = function() {
  var editorHeight  = textarea.scrollHeight - textarea.clientHeight,
      previewHeight = preview.scrollHeight - preview.clientHeight,
      scrollRatio   = textarea.scrollTop / editorHeight,
      imgs          = preview.getElementsByTagName('img')

  Array.prototype.forEach.call(imgs, function(img) {
    previewHeight += 1/scrollRatio * img.height
  })

  preview.scrollTop = previewHeight * scrollRatio;
}

// Event handling

window.setTimeout(function() {
  updatePreview()
  window.setTimeout(arguments.callee, 1000)
}, 0)

textarea.addEventListener('scroll', scrollPreview);
textarea.addEventListener('keyup', function(ev) {
  dirty = true
}, false)

previewLink.addEventListener('click', function(ev) {
  togglePreview()
  ev.preventDefault()
})

saveButton.addEventListener('click', function(ev) {
  document.forms[0].submit()
  ev.preventDefault()
}, false)

keymage('alt-p', togglePreview, {preventDefault: true})
