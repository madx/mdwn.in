var sourceField   = document.getElementsByName('document[source]')[0],
    originalField = document.getElementsByName('document[original]')[0],
    keyField      = document.getElementsByName('document[key]')[0],
    captchaField  = document.getElementsByName('document[donotfill]')[0],
    preview       = document.getElementById('preview'),
    previewLink   = document.getElementById('preview-link'),
    previewImage  = previewLink.getElementsByTagName('img')[0],
    saveButton    = document.querySelector('a[href="#save"]'),
    cancelButton  = document.querySelector('a[href="#cancel"]'),
    saveStatus    = document.getElementById('saveStatus'),
    pos           = sourceField.value.length * 2,
    dirty         = false

sourceField.focus()
sourceField.setSelectionRange(pos, pos)
captchaField.style.display = 'none'

// Preview-related function

var updatePreview = function() {
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

var saveDocument = function() {
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

var togglePreview = function() {
  if (window.location.hash == '#preview') {
    scrollEditor()
    previewImage.setAttribute('src', '/images/eye.png')
    previewLink.setAttribute('title', 'Preview changes (Alt-P)')
    sourceField.focus()

    window.location.hash = ''
  } else {
    scrollPreview()
    previewImage.setAttribute('src', '/images/pencil.png')
    previewLink.setAttribute('title', 'Edit document (Alt-P)')

    window.location.hash = '#preview'
  }
}

var scrollPreview = function() {
  var editorHeight  = sourceField.scrollHeight - sourceField.clientHeight,
      previewHeight = preview.scrollHeight - preview.clientHeight,
      scrollRatio   = sourceField.scrollTop / editorHeight

  preview.scrollTop = previewHeight * scrollRatio
}

var scrollEditor = function() {
  var editorHeight  = sourceField.scrollHeight - sourceField.clientHeight,
      previewHeight = preview.scrollHeight - preview.clientHeight,
      scrollRatio   = preview.scrollTop / previewHeight

  sourceField.scrollTop = editorHeight * scrollRatio
}

// Event handling

window.setTimeout(function() {
  if (dirty) {
    updatePreview()
    if (keyField !== undefined) saveDocument()
  }
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

if (cancelButton) {
  cancelButton.addEventListener('click', function(ev) {
    sourceField.value = originalField.value
    document.forms[0].submit()
    ev.preventDefault()
  }, false)
}

keymage('alt-p', togglePreview, {preventDefault: true})

updatePreview()
