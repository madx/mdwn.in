var textarea    = document.getElementsByName('document[source]')[0],
    keyField    = document.getElementsByName('document[key]')[0],
    preview     = document.getElementById('preview'),
    previewLink = document.getElementById('preview-link'),
    saveButton  = document.querySelector('a[href="#save"]'),
    saveStatus  = document.getElementById('saveStatus'),
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
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest')
  xhr.send('source=' + encodeURIComponent(textarea.value))
}

saveDocument = function() {
  if (!dirty) return;
  var xhr = new XMLHttpRequest()
  xhr.onreadystatechange = function() {
    if (xhr.readyState == 4) {
      if(xhr.status == 200) {
        saveStatus.classList.remove('error');
        saveStatus.classList.add('notice');
      } else {
        saveStatus.classList.add('error');
        saveStatus.classList.remove('notice');
      }
      saveStatus.textContent = xhr.responseText;
    }
  }
  xhr.open('PUT', '/'+keyField.value, true)
  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest')
  xhr.send('document[source]=' + encodeURIComponent(textarea.value))
}

togglePreview = function() {
  if (window.location.hash == '#preview') {
    scrollEditor()
    previewLink.textContent = 'P'
    previewLink.setAttribute('title', 'Preview changes (Alt-P)')
    textarea.focus()

    window.location.hash = ''
  } else {
    scrollPreview()
    previewLink.textContent = 'E'
    previewLink.setAttribute('title', 'Edit document (Alt-P)')

    window.location.hash = '#preview'
  }
}

scrollPreview = function() {
  var editorHeight  = textarea.scrollHeight - textarea.clientHeight,
      previewHeight = preview.scrollHeight - preview.clientHeight,
      scrollRatio   = textarea.scrollTop / editorHeight

  preview.scrollTop = previewHeight * scrollRatio
}

scrollEditor = function() {
  var editorHeight  = textarea.scrollHeight - textarea.clientHeight,
      previewHeight = preview.scrollHeight - preview.clientHeight,
      scrollRatio   = preview.scrollTop / previewHeight

  textarea.scrollTop = editorHeight * scrollRatio
}

// Event handling

window.setTimeout(function() {
  updatePreview()
  if (keyField !== undefined)
    saveDocument()
  window.setTimeout(arguments.callee, 1000)
}, 0)

  saveDocument()

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
