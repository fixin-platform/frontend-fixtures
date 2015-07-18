if Package.type is "extension"
  FlowRouter.initialize = ->

setAppTitle = (context, redirect) ->
  return if Pack.isApplied
  app = Apps.findOne({key: context.params.appKey})
  Foreach.setPageTitle("#{app.name} + bulk actions = ♥", false)

#FlowRouter.triggers.enter([AccountsTemplates.ensureSignedIn], {except: ["index"]});
#, except: ["pricing", "pricingByPeriod", "disclaimer", "autologin", "apps", "app", "blueprintTeaser"]
SecureFlowRouter = FlowRouter.group
  middlewares: [AccountsTemplates.ensureSignedIn]

Pack.call("preRouting")

FlowRouter.notFound = action: -> FlowLayout.render "layout", content: "notFound"

FlowRouter.route "/",
  name: "index"
  triggersEnter: [
    (context, redirect) ->
      $('.modal-backdrop').remove();
      redirect(Pack.get("homeUrl") or "/Trello")
  ]

FlowRouter.route "/pricing", triggersEnter: (context, redirect) -> redirect("/pricing/per/month")
FlowRouter.route "/pricing/per/:period", action: -> FlowLayout.render "layout", content: "pricing"
FlowRouter.route "/disclaimer", action: -> FlowLayout.render "layout", content: "disclaimer"

FlowRouter.route "/apps",
  triggersEnter: [
    (context, redirect) ->
      selector = Pack.call("getAppsSelector") or {}
      cursor = Apps.find(selector)
      redirect(cursor.fetch()[0].url()) if cursor.count() is 1 # pack has only one app, redirect to its recipes at once
  ]
  action: -> FlowLayout.render "layout", content: "apps"

SecureFlowRouter.route "/dashboard", action: -> FlowLayout.render "layout", content: "dashboard"
SecureFlowRouter.route "/stats", action: -> FlowLayout.render "layout", content: "stats"
SecureFlowRouter.route "/health", action: -> FlowLayout.render "layout", content: "health"
SecureFlowRouter.route "/iframe/:appKey", action: -> FlowLayout.render "layout", content: "iframe"

SecureFlowRouter.route "/autologin/:token",
  triggersEnter: (context, redirect) ->
    Meteor.loginWithToken(context.params.token)
    Foreach.autologinDetected = true
    redirect("/")

FlowRouter.route "/:appKey",
  triggersEnter: [setAppTitle]
  action: -> FlowLayout.render "layout", content: "app"

FlowRouter.route "/:appKey/:blueprintKey",
  triggersEnter: [setAppTitle]
  action: -> FlowLayout.render "layout", content: "blueprintTeaser"

SecureFlowRouter.route "/:appKey/:blueprintKey/:recipeId",
  triggersEnter: [setAppTitle]
  action: -> FlowLayout.render "layout", content: "recipe"

#if Meteor.settings.public.isMaintenance
#  Router.onBeforeAction ->
#    @layout("cleanLayout")
#    @render("maintenance")
#
#Router.onBeforeAction ->
#  if Meteor.userId() or (Foreach.getParam("appKey") and Foreach.getParam("appKey") isnt "Trello" and not Pack.isApplied)
#    @next()
#  else
#    @layout("cleanLayout")
#    @render(Pack.get("welcomeTemplate", "welcome"))
##    # I've noticed UnauthenticatedPageview fire twice on user login
##    mixpanel.track("UnauthenticatedPageview")
#    sendPageview()
#, except: ["pricing", "pricingByPeriod", "disclaimer", "autologin", "apps", "blueprintTeaser"] # "app" route is processed manually in this hook

FlowRouter.triggers.exit([sendPageview])

FlowRouter.triggers.enter([
  -> $(window).scrollTop(0) # try fixing the lagging scroll issue when logging in from mobile devices while having already scrolled down the page
])

Foreach.setPageTitle = (title, appendSiteName = true) ->
  if appendSiteName
    title += " - Foreach"
  if Meteor.settings.public.isDebug
    title = "(D) " + title
  document.title = title

if location.pathname is "/trello" # temp BC
  FlowRouter.go("/Trello")

Pack.call("postRouting")
