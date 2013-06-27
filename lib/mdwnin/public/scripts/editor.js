var sourceField   = document.getElementsByName('document[source]')[0],
    originalField = document.getElementsByName('document[original]')[0],
    keyField      = document.getElementsByName('document[key]')[0],
    preview       = document.getElementById('preview'),
    previewLink   = document.getElementById('preview-link'),
    saveButton    = document.querySelector('a[href="#save"]'),
    cancelButton  = document.querySelector('a[href="#cancel"]'),
    saveStatus    = document.getElementById('saveStatus'),
    pos           = sourceField.value.length * 2,
    dirty         = true

sourceField.focus()
sourceField.setSelectionRange(pos, pos)

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
  xhr.send('source=' + encodeURIComponent(sourceField.value))
}

saveDocument = function() {
  if (!dirty) return;
  var xhr = new XMLHttpRequest()
  xhr.onreadystatechange = function() {
    if (xhr.readyState == 4) {
      if(xhr.status == 200) {
        saveStatus.classList.remove('error')
        saveStatus.classList.add('notice')
      } else {
        saveStatus.classList.add('error')
        saveStatus.classList.remove('notice')
      }
      saveStatus.textContent = xhr.responseText;
    }
  }
  xhr.open('PUT', '/'+keyField.value, true)
  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest')
  xhr.send('document[source]=' + encodeURIComponent(sourceField.value))
}

togglePreview = function() {
  if (window.location.hash == '#preview') {
    scrollEditor()
    previewLink.textContent = 'P'
    previewLink.setAttribute('title', 'Preview changes (Alt-P)')
    sourceField.focus()

    window.location.hash = ''
  } else {
    scrollPreview()
    previewLink.textContent = 'E'
    previewLink.setAttribute('title', 'Edit document (Alt-P)')

    window.location.hash = '#preview'
  }
}

scrollPreview = function() {
  var editorHeight  = sourceField.scrollHeight - sourceField.clientHeight,
      previewHeight = preview.scrollHeight - preview.clientHeight,
      scrollRatio   = sourceField.scrollTop / editorHeight

  preview.scrollTop = previewHeight * scrollRatio
}

scrollEditor = function() {
  var editorHeight  = sourceField.scrollHeight - sourceField.clientHeight,
      previewHeight = preview.scrollHeight - preview.clientHeight,
      scrollRatio   = preview.scrollTop / previewHeight

  sourceField.scrollTop = editorHeight * scrollRatio
}

// Event handling

window.setTimeout(function() {
  updatePreview()
  if (keyField !== undefined)
    saveDocument()
  window.setTimeout(arguments.callee, 1000)
}, 0)

sourceField.addEventListener('keyup', function(ev) {
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

cancelButton.addEventListener('click', function(ev) {
  sourceField.value = originalField.value
  document.forms[0].submit()
  ev.preventDefault()
}, false)

keymage('alt-p', togglePreview, {preventDefault: true})
