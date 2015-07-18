pack = Pack.call("getFixtures") or {}
_.extend(Foreach.fixtureApps, pack.apps or {})
_.extend(Foreach.fixtureBlueprints, pack.blueprints or {})
_.extend(Foreach.fixtureRecipes, pack.recipes or {})
_.extend(Foreach.fixtureSteps, pack.steps or {})

Foreach.loadFixtures = (reloadedCollectionNames) ->
  now = new Date()
  lastWeek = new Date(now.getTime() - 7 * 24 * 3600 * 1000)

  insertData(Foreach.fixtureApps, Apps, reloadedCollectionNames)

  insertData(Foreach.fixtureBlueprints, Blueprints, reloadedCollectionNames)

  insertData(Foreach.fixtureRecipes, Recipes, reloadedCollectionNames)

  insertData(Foreach.fixtureSteps, Steps, reloadedCollectionNames)

  users =
    DenisGorbachev:
      profile:
        name: "Denis Gorbachev"
        isRealName: true
      isAdmin: true
    ArunodaSusiripala:
      profile:
        name: "Arunoda Susiripala"
        isRealName: true
  _.extend(users, pack.users or {})
  for _id, user of users
    _.defaults(user,
      username: _id
      isAliasedByMixpanel: true
      emails: [
        {
          address: _id.toLowerCase() + "@foreach.io"
          verified: true
        }
      ]
      createdAt: lastWeek
    )

  insertedUserIds = insertData(users, Users, reloadedCollectionNames)
  for userId in insertedUserIds
    Accounts.setPassword(userId, "123123")
    Users.update(userId, {$push: {"services.resume.loginTokens": {
      hashedToken: Accounts._hashLoginToken(userId),
      when: now
    }}})

  filters =
    listFilter:
      field: "idList"
      operator: "is"
#      value: "Doing"
      andGroupId: 1
      userId: "ArunodaSusiripala"
    membersFilter:
      field: "idMembers"
      operator: "is"
#      value: "Brad Pitt"
      andGroupId: 2
      userId: "ArunodaSusiripala"
    dueDateFilter:
      field: "due"
      operator: "isBetween"
      valueFrom: "01/14/2015"
      valueTo: "01/20/2015"
      andGroupId: 1
      userId: "ArunodaSusiripala"
  insertData(_.extend(filters, pack.filters or {}), TrelloFilters, reloadedCollectionNames)

  votes =
    "500pxSetLicenseFirst":
      appId: "500px"
      action: "set-license"
      userId: "DenisGorbachev"
    "500pxDeleteFirst":
      appId: "500px"
      action: "delete"
      userToken: "token_J7H9PNSNPQL5jymRx"
    "500pxDeleteSecond":
      appId: "500px"
      action: "delete"
      userToken: "token_8ZK3694dmtz4xPvTF"
  insertData(_.extend(votes, pack.votes or {}), Votes, reloadedCollectionNames)

  serviceConfigurations = {}
  if Meteor.settings.public.google
    serviceConfigurations.Google =
      service: "google"
      clientId: Meteor.settings.public.google.clientId,
      secret: Meteor.settings.google.secret
  if Meteor.settings.public.twitter
    serviceConfigurations.Twitter =
      service: "twitter"
      consumerKey: Meteor.settings.public.twitter.consumerKey,
      secret: Meteor.settings.twitter.secret
  insertData(_.extend(serviceConfigurations, pack.serviceConfigurations or {}), ServiceConfiguration.configurations, reloadedCollectionNames)

Foreach.databaseReset = not Migrations._collection.findOne("control")
