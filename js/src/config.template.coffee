@config =
    templateBaseUrl: '/views/',
    useHtml5Mode: false,
    projectSheetTemplateSlug: 'unisson',
    defaultSiteTags: ['Mobilité','SEL'],  # comma-separated list of site tags
    
    # Commons-dev patapouf server
    bucket_uri: 'http://example.org/bucket/upload/',
    loginBaseUrl: 'http://example.org/api/v0', # This can be different from rest_uri
    oauthBaseUrl: 'http://imagination.apps.patapouf.org', #path to oauth.html
    oauthCliendId: 'YOUR_OAUTH_ID',
    media_uri: 'http://example.org',
    rest_uri: "http://example.org/api/v0",
    dataserver_url: "http://example.org"