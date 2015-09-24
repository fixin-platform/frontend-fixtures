Fixtures =
  buckets: []
  preHooks: []
  postHooks: []
  objectIds: []

  push: (collection, objects) ->
    bucket = _.find @buckets, (bucket) -> bucket.collection is collection
    if bucket
      _.extend bucket.objects, objects
    else
      @buckets.push
        collection: collection
        objects: objects

  pre: (collection, handler) ->
    @preHooks.push
      collection: collection
      handler: handler

  post: (collection, handler) ->
    @postHooks.push
      collection: collection
      handler: handler

  insertAll: (reloadedCollectionNames) ->
    for bucket in @buckets
      hook.handler(bucket.objects) for hook in @preHooks when hook.collection is bucket.collection
      @insert(bucket.objects, bucket.collection, reloadedCollectionNames)
      hook.handler(bucket.objects) for hook in @postHooks when hook.collection is bucket.collection

  insert: (objects, collection, reloadedCollectionNames) ->
    @objectIds.push(_id) for _id, object of objects when _id not in @objectIds
    return [] if collection._name not in reloadedCollectionNames and reloadedCollectionNames.length
    return [] if collection.find().count()
    for _id, object of objects
      object._id = _id
      collection.insert(object)

  ensureAll: (collectionNames) ->
    for bucket in @buckets
      @ensure(bucket.objects, bucket.collection, collectionNames)

  ensure: (objects, collection, collectionNames = []) ->
    return [] if collection._name not in collectionNames
    for _id, object of objects
      if collection.findOne(_id) # using manual "upsert" to trigger the hooks
        collection.update(_id, {$set: object})
      else
        object._id = _id
        collection.insert(object)
