CodeSync.plugins.StylesheetLoader = CodeSync.EditorUtility.extend
  buttonIcon: "cloud"
  className: "stylesheet-loader"
  tooltip: "Load external stylesheets"
  panelTemplate: "stylesheet_loader"
  availableInModes:"stylesheet"
  handle: "stylesheetLoader"

  templateOptions: ()->
    packages: @packages

  initialize:(@options={})->
    @packages = new CodeSync.StylesheetPackages()

    @packages.fetch success: ()=> @packages.add(CodeSync.StylesheetPackages.samples) if @packages.length is 0

    CodeSync.EditorUtility::initialize.apply(@, arguments)

  events:
    "click .submit"           : "loadResources"
    "click .save-as-package"  : "savePackage"
    "click .finished"         : "toggle"
    "change select"           : "loadPackage"

  loadPackage: (e)->
    target        = @$(e.target).closest('select')
    package_name  = target.val()

    model = @packages.detect (model)-> model.get("name") is package_name

    if model?
      @$('textarea').val model.get('list').join("\n")

  toggle: ()->
    @$('.card').removeClass('active')
    @$('.card.menu').addClass('active')
    CodeSync.EditorUtility::toggle.call(@, withEffect: true)

  savePackage: (e)->
    target = @$(e.target).closest('.btn')
    panel = @

    @package?.save success: ()->
      target.html("Success")

      _.delay ()->
        target.html "Save as Package"
        panel.reset()
      , 1000

  showRequestStatus: (pkg)->
    container = @$('.results-container').empty()

    for script, status of pkg.get('status')
      icon = if status then 'loop' else 'retweet'
      cls = if status then "success" else "danger"
      container.append "<li>#{ script }<span class='status-indicator #{ cls }'><i class='icon icon-#{ icon }' /></span></li>"

  getWindow: ()->
    @editor?.targetWindow || @editorPanel?.targetWindow || window

  loadResources: ()->
    name = @$('select').val()
    list = @$('textarea').val()

    if @package?
      @package.off "change"

    @package = @packages.create(name:name,text:list)

    @package.on "resource:loaded", @showRequestStatus, @

    @$('.card').removeClass('active')
    @$('.card.results').addClass('active')

    @package.request(@getWindow())