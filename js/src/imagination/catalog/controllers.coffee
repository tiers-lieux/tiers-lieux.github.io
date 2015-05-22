module = angular.module("imagination.catalog.controllers", ['commons.graffiti.controllers', "commons.accounts.controllers", "commons.accounts.services", 
                                                        'commons.base.services','commons.catalog.services'])

# module.controller("MakerScienceProjectListCtrl", ($scope, $controller, MakerScienceProject) ->
#     angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))
    
#     $scope.refreshList = ()->
#         $scope.projects = MakerScienceProject.one().customGETLIST('search', $scope.params).$object
    
# )


module.controller("ImaginationProjectSheetCreateCtrl", ($scope, $state, $controller, Project, ProjectSheet, TaggedItem, Profile, ObjectProfileLink) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})

    $scope.tags = []

    $scope.saveImaginationProject = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            return false
        else
            console.log("submitting form")
        
        $scope.saveProject().then((projectsheetResult) ->
            console.log(" Just saved project : Result from savingProject : ", projectsheetResult)
            
            # Here we assign tags to projects 
            angular.forEach($scope.tags, (tag)->
                TaggedItem.one().customPOST({tag : tag.text}, "project/"+projectsheetResult.project.id, {})
            )

            $scope.saveVideos(projectsheetResult.id)
            # if no photos to upload, directly go to new project sheet
            if $scope.uploader.queue.length <= 0
                $state.go("project.detail", {slug : projectsheetResult.project.slug})
            else
                $scope.savePhotos(projectsheetResult.id, projectsheetResult.bucket.id)
                $scope.uploader.onCompleteAll = () ->
                    $state.go("project.detail", {slug : projectsheetResult.project.slug})
            
            # add connected user as team member of project with detail "porteur"
            # FIXME : 
            # a) check currentProfile get populated (see commons.accounts.services)
            # b) implement permissions !
        )
)

module.controller("ImaginationProjectSheetCtrl", ($rootScope, $scope, $stateParams, $controller, $modal, Project, 
                        ProjectSheet, TaggedItem, ObjectProfileLink, DataSharing, ProjectSheetTemplate, 
                        ProjectSheetQuestionAnswer, PostalAddress, geolocation) ->

    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('TaggedItemCtrl', {$scope: $scope})

    $scope.preparedTags = []
    $scope.currentUserHasEditRights = false
    $scope.editable = false
    $scope.countryData = [{"id":"AF","text":"Afghanistan"},{"id":"AX","text":"Åland Islands"},{"id":"AL","text":"Albania"},{"id":"DZ","text":"Algeria"},{"id":"AS","text":"American Samoa"},{"id":"AD","text":"Andorra"},{"id":"AO","text":"Angola"},{"id":"AI","text":"Anguilla"},{"id":"AQ","text":"Antarctica"},{"id":"AG","text":"Antigua and Barbuda"},{"id":"AR","text":"Argentina"},{"id":"AM","text":"Armenia"},{"id":"AW","text":"Aruba"},{"id":"AU","text":"Australia"},{"id":"AT","text":"Austria"},{"id":"AZ","text":"Azerbaijan"},{"id":"BS","text":"Bahamas"},{"id":"BH","text":"Bahrain"},{"id":"BD","text":"Bangladesh"},{"id":"BB","text":"Barbados"},{"id":"BY","text":"Belarus"},{"id":"BE","text":"Belgium"},{"id":"BZ","text":"Belize"},{"id":"BJ","text":"Benin"},{"id":"BM","text":"Bermuda"},{"id":"BT","text":"Bhutan"},{"id":"BO","text":"Bolivia"},{"id":"BQ","text":"Bonaire"},{"id":"BA","text":"Bosnia and Herzegovina"},{"id":"BW","text":"Botswana"},{"id":"BV","text":"Bouvet Island"},{"id":"BR","text":"Brazil"},{"id":"IO","text":"British Indian Ocean Territory"},{"id":"VG","text":"British Virgin Islands"},{"id":"BN","text":"Brunei"},{"id":"BG","text":"Bulgaria"},{"id":"BF","text":"Burkina Faso"},{"id":"BI","text":"Burundi"},{"id":"KH","text":"Cambodia"},{"id":"CM","text":"Cameroon"},{"id":"CA","text":"Canada"},{"id":"CV","text":"Cape Verde"},{"id":"KY","text":"Cayman Islands"},{"id":"CF","text":"Central African Republic"},{"id":"TD","text":"Chad"},{"id":"CL","text":"Chile"},{"id":"CN","text":"China"},{"id":"CX","text":"Christmas Island"},{"id":"CC","text":"Cocos (Keeling) Islands"},{"id":"CO","text":"Colombia"},{"id":"KM","text":"Comoros"},{"id":"CG","text":"Republic of the Congo"},{"id":"CD","text":"DR Congo"},{"id":"CK","text":"Cook Islands"},{"id":"CR","text":"Costa Rica"},{"id":"HR","text":"Croatia"},{"id":"CU","text":"Cuba"},{"id":"CW","text":"Curaçao"},{"id":"CY","text":"Cyprus"},{"id":"CZ","text":"Czech Republic"},{"id":"DK","text":"Denmark"},{"id":"DJ","text":"Djibouti"},{"id":"DM","text":"Dominica"},{"id":"DO","text":"Dominican Republic"},{"id":"EC","text":"Ecuador"},{"id":"EG","text":"Egypt"},{"id":"SV","text":"El Salvador"},{"id":"GQ","text":"Equatorial Guinea"},{"id":"ER","text":"Eritrea"},{"id":"EE","text":"Estonia"},{"id":"ET","text":"Ethiopia"},{"id":"FK","text":"Falkland Islands"},{"id":"FO","text":"Faroe Islands"},{"id":"FJ","text":"Fiji"},{"id":"FI","text":"Finland"},{"id":"FR","text":"France"},{"id":"GF","text":"French Guiana"},{"id":"PF","text":"French Polynesia"},{"id":"TF","text":"French Southern and Antarctic Lands"},{"id":"GA","text":"Gabon"},{"id":"GM","text":"Gambia"},{"id":"GE","text":"Georgia"},{"id":"DE","text":"Germany"},{"id":"GH","text":"Ghana"},{"id":"GI","text":"Gibraltar"},{"id":"GR","text":"Greece"},{"id":"GL","text":"Greenland"},{"id":"GD","text":"Grenada"},{"id":"GP","text":"Guadeloupe"},{"id":"GU","text":"Guam"},{"id":"GT","text":"Guatemala"},{"id":"GG","text":"Guernsey"},{"id":"GN","text":"Guinea"},{"id":"GW","text":"Guinea-Bissau"},{"id":"GY","text":"Guyana"},{"id":"HT","text":"Haiti"},{"id":"HM","text":"Heard Island and McDonald Islands"},{"id":"VA","text":"Vatican City"},{"id":"HN","text":"Honduras"},{"id":"HK","text":"Hong Kong"},{"id":"HU","text":"Hungary"},{"id":"IS","text":"Iceland"},{"id":"IN","text":"India"},{"id":"ID","text":"Indonesia"},{"id":"CI","text":"Ivory Coast"},{"id":"IR","text":"Iran"},{"id":"IQ","text":"Iraq"},{"id":"IE","text":"Ireland"},{"id":"IM","text":"Isle of Man"},{"id":"IL","text":"Israel"},{"id":"IT","text":"Italy"},{"id":"JM","text":"Jamaica"},{"id":"JP","text":"Japan"},{"id":"JE","text":"Jersey"},{"id":"JO","text":"Jordan"},{"id":"KZ","text":"Kazakhstan"},{"id":"KE","text":"Kenya"},{"id":"KI","text":"Kiribati"},{"id":"KW","text":"Kuwait"},{"id":"KG","text":"Kyrgyzstan"},{"id":"LA","text":"Laos"},{"id":"LV","text":"Latvia"},{"id":"LB","text":"Lebanon"},{"id":"LS","text":"Lesotho"},{"id":"LR","text":"Liberia"},{"id":"LY","text":"Libya"},{"id":"LI","text":"Liechtenstein"},{"id":"LT","text":"Lithuania"},{"id":"LU","text":"Luxembourg"},{"id":"MO","text":"Macau"},{"id":"MK","text":"Macedonia"},{"id":"MG","text":"Madagascar"},{"id":"MW","text":"Malawi"},{"id":"MY","text":"Malaysia"},{"id":"MV","text":"Maldives"},{"id":"ML","text":"Mali"},{"id":"MT","text":"Malta"},{"id":"MH","text":"Marshall Islands"},{"id":"MQ","text":"Martinique"},{"id":"MR","text":"Mauritania"},{"id":"MU","text":"Mauritius"},{"id":"YT","text":"Mayotte"},{"id":"MX","text":"Mexico"},{"id":"FM","text":"Micronesia"},{"id":"MD","text":"Moldova"},{"id":"MC","text":"Monaco"},{"id":"MN","text":"Mongolia"},{"id":"ME","text":"Montenegro"},{"id":"MS","text":"Montserrat"},{"id":"MA","text":"Morocco"},{"id":"MZ","text":"Mozambique"},{"id":"MM","text":"Myanmar"},{"id":"NA","text":"Namibia"},{"id":"NR","text":"Nauru"},{"id":"NP","text":"Nepal"},{"id":"NL","text":"Netherlands"},{"id":"NC","text":"New Caledonia"},{"id":"NZ","text":"New Zealand"},{"id":"NI","text":"Nicaragua"},{"id":"NE","text":"Niger"},{"id":"NG","text":"Nigeria"},{"id":"NU","text":"Niue"},{"id":"NF","text":"Norfolk Island"},{"id":"KP","text":"North Korea"},{"id":"MP","text":"Northern Mariana Islands"},{"id":"NO","text":"Norway"},{"id":"OM","text":"Oman"},{"id":"PK","text":"Pakistan"},{"id":"PW","text":"Palau"},{"id":"PS","text":"Palestine"},{"id":"PA","text":"Panama"},{"id":"PG","text":"Papua New Guinea"},{"id":"PY","text":"Paraguay"},{"id":"PE","text":"Peru"},{"id":"PH","text":"Philippines"},{"id":"PN","text":"Pitcairn Islands"},{"id":"PL","text":"Poland"},{"id":"PT","text":"Portugal"},{"id":"PR","text":"Puerto Rico"},{"id":"QA","text":"Qatar"},{"id":"XK","text":"Kosovo"},{"id":"RE","text":"Réunion"},{"id":"RO","text":"Romania"},{"id":"RU","text":"Russia"},{"id":"RW","text":"Rwanda"},{"id":"BL","text":"Saint Barthélemy"},{"id":"SH","text":"Saint Helena, Ascension and Tristan da Cunha"},{"id":"KN","text":"Saint Kitts and Nevis"},{"id":"LC","text":"Saint Lucia"},{"id":"MF","text":"Saint Martin"},{"id":"PM","text":"Saint Pierre and Miquelon"},{"id":"VC","text":"Saint Vincent and the Grenadines"},{"id":"WS","text":"Samoa"},{"id":"SM","text":"San Marino"},{"id":"ST","text":"São Tomé and Príncipe"},{"id":"SA","text":"Saudi Arabia"},{"id":"SN","text":"Senegal"},{"id":"RS","text":"Serbia"},{"id":"SC","text":"Seychelles"},{"id":"SL","text":"Sierra Leone"},{"id":"SG","text":"Singapore"},{"id":"SX","text":"Sint Maarten"},{"id":"SK","text":"Slovakia"},{"id":"SI","text":"Slovenia"},{"id":"SB","text":"Solomon Islands"},{"id":"SO","text":"Somalia"},{"id":"ZA","text":"South Africa"},{"id":"GS","text":"South Georgia"},{"id":"KR","text":"South Korea"},{"id":"SS","text":"South Sudan"},{"id":"ES","text":"Spain"},{"id":"LK","text":"Sri Lanka"},{"id":"SD","text":"Sudan"},{"id":"SR","text":"Suriname"},{"id":"SJ","text":"Svalbard and Jan Mayen"},{"id":"SZ","text":"Swaziland"},{"id":"SE","text":"Sweden"},{"id":"CH","text":"Switzerland"},{"id":"SY","text":"Syria"},{"id":"TW","text":"Taiwan"},{"id":"TJ","text":"Tajikistan"},{"id":"TZ","text":"Tanzania"},{"id":"TH","text":"Thailand"},{"id":"TL","text":"Timor-Leste"},{"id":"TG","text":"Togo"},{"id":"TK","text":"Tokelau"},{"id":"TO","text":"Tonga"},{"id":"TT","text":"Trinidad and Tobago"},{"id":"TN","text":"Tunisia"},{"id":"TR","text":"Turkey"},{"id":"TM","text":"Turkmenistan"},{"id":"TC","text":"Turks and Caicos Islands"},{"id":"TV","text":"Tuvalu"},{"id":"UG","text":"Uganda"},{"id":"UA","text":"Ukraine"},{"id":"AE","text":"United Arab Emirates"},{"id":"GB","text":"United Kingdom"},{"id":"US","text":"United States"},{"id":"UM","text":"United States Minor Outlying Islands"},{"id":"VI","text":"United States Virgin Islands"},{"id":"UY","text":"Uruguay"},{"id":"UZ","text":"Uzbekistan"},{"id":"VU","text":"Vanuatu"},{"id":"VE","text":"Venezuela"},{"id":"VN","text":"Vietnam"},{"id":"WF","text":"Wallis and Futuna"},{"id":"EH","text":"Western Sahara"},{"id":"YE","text":"Yemen"},{"id":"ZM","text":"Zambia"},{"id":"ZW","text":"Zimbabwe"}];
    # Minimap scope data
    $scope.defaults = {
            scrollWheelZoom: true # Keep the scrolling working on the page, not in the map
            maxZoom: 14
            minZoom: 1
    }
    $scope.center = {
            lat: 46.43
            lng: 2.35
            zoom: 5
    }
    $scope.markers = [
            lat: 46.43
            lng: 2.35
        ]

    # Methods definitions
    $scope.showCountry = (countryCode)->
        selected_country = _.find($scope.countryData, (country)->
                return country.id == countryCode
            )
        if selected_country
            return selected_country.text
        else
            return null

    $scope.buildAddress = ()->
        address = ''
        if $scope.project.location.address && $scope.project.location.address.street_address
            address+=$scope.project.location.address.street_address
        if $scope.project.location.address && $scope.project.location.address.country
            address+=', '
            address+=$scope.showCountry($scope.project.location.address.country)
        return address

    $scope.addMarker = (lat, lng, address)->
        marker = {
            lat: lat
            lng: lng
            message: address
            icon:
                    type: 'awesomeMarker'
                    prefix: 'fa'
                    markerColor: "blue"
                    iconColor: "white"
        }
        $scope.markers = [marker]
        # centre la carte sur le marker
        $scope.center = {
            lat: lat
            lng: lng
            zoom: 3
        }

    $scope.geocodeAddress = ()->
        lookup_address = $scope.buildAddress()
        pos_promise = geolocation.lookupAddress(lookup_address).then((coords)->
            console.log(" found position !", coords)
            $scope.addMarker(coords[0], coords[1], lookup_address)
        )

    $scope.loadGeocodedLocation = ()->
        if $scope.project.location && $scope.project.location.geo
            address = $scope.buildAddress()
            lat = $scope.project.location.geo.coordinates[1]
            lng = $scope.project.location.geo.coordinates[0] 
            $scope.addMarker(lat, lng, address)
        # no geo data yet
        else if $scope.project.location && $scope.project.location.address
            console.log(" Try geocoding given address ")
            $scope.geocodeAddress()

    $scope.isQuestionInQA = (question, question_answers) ->
        return _.find(question_answers, (item) ->
                return item.question.resource_uri == question.resource_uri
        ) != undefined

    $scope.populateQuestions = ()->
        if not $scope.projectsheet.template.questions
            ProjectSheetTemplate.one(getObjectIdFromURI($scope.projectsheet.template)).get().then((result)->
                $scope.projectsheet.template = result
                console.log(" project sheet ready", $scope.projectsheet)
                for question in $scope.projectsheet.template.questions
                    console.log("Checking questions ? ", question)
                    if !$scope.isQuestionInQA(question, $scope.projectsheet.question_answers)
                        # Then we post a new q_a
                        console.log("posting new QA !")
                        q_a = {
                            question: question.resource_uri
                            answer: ''
                            projectsheet: $scope.projectsheet.resource_uri
                        }
                        ProjectSheetQuestionAnswer.post(q_a).then((result)->
                            console.log("posted new QA ", result)
                            $scope.projectsheet.question_answers.push(result)
                        )
            )

    $scope.updateImaginationProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'Project' then Project.one(resourceId).patch(putData)
            when 'ProjectSheet' then ProjectSheet.one(resourceId).patch(putData)

    
    $scope.updateProjectAddress = (resourceId, fieldName, data)->
        # Update already existing adress
        if $scope.project.location && $scope.project.location.address
            # update address 
            putData = {}
            putData[fieldName] = data
            PostalAddress.one($scope.project.location.address.id).patch(putData).then((data)->
                $scope.project.location.address = data
                console.log(" updated project location!", $scope.project)
                # Try geocoding newly edited address
                $scope.geocodeAddress()
            )
        # Update or create location data without already existing adress
        else
            putData = {
                location:{
                    address:{
                    }
                }
            }
            # check if already existing geo data
            if $scope.project.location && $scope.project.location.geo
                putData.location['geo'] = $scope.project.location.geo
            putData.location.address[fieldName] = data
            Project.one(resourceId).patch(putData).then((data)->
                $scope.project['location'] = data.location
                console.log(" created project location!", $scope.project)
                # Try geocoding newly edited address
                $scope.geocodeAddress()
                )

    $scope.updateGeolocation = (project_id)->
        # update if already existing geodata
        putData = {
            location :{
                geo: {
                    coordinates:[$scope.markers[0].lng, $scope.markers[0].lat]
                    type:"Point"
                }
            }
        }
        if $scope.project.location && $scope.project.location.address
            putData['address'] = $scope.project.location.address
        
        Project.one(project_id).patch(putData).then((data)->
            console.log(" Updated GEO location!", data)
            )



    # FIXME : use this for dedicated interface for geocoding
    $scope.openGeocodingPopup = () ->
        modalInstance = $modal.open(
            templateUrl: 'views/catalog/block/geocoding.html'
            controller: 'GeocodingInstanceCtrl'
            size: 'lg'
            resolve:
                params: ->
                    return {
                        project : $scope.project
                        countryData : $scope.countryData
                        showCountry : $scope.showCountry
                    }
        )   

    # Load projectsheet data
    ProjectSheet.one().get({'project__slug' : $stateParams.slug}).then((ProjectSheetResult) ->
        $scope.projectsheet = ProjectSheetResult.objects[0]
        $scope.project = $scope.projectsheet.project
        
        DataSharing.sharedObject = {project: $scope.projectsheet.project}
        angular.forEach($scope.projectsheet.project.tags, (taggedItem) ->
            $scope.preparedTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.loadGeocodedLocation()

    )
)

module.controller('GeocodingInstanceCtrl', ($scope, $rootScope, $modalInstance, params, geolocation) ->
    console.log('Init GeocodingInstanceCtrl', params)
    $scope.project = params.project
    $scope.countryData = params.countryData
    $scope.showCountry = params.showCountry
    $scope.markers = []
    $scope.defaults = {
            scrollWheelZoom: true # Keep the scrolling working on the page, not in the map
            maxZoom: 14
            minZoom: 1
    }
    $scope.center = {
            lat: 46.43
            lng: 2.35
            zoom: 5
    }

    $scope.ok = ->
        geo = {}
        $modalInstance.close(geo)

    $scope.cancel = ->
        $modalInstance.dismiss('cancel')

    $scope.geocode = ()->
        lookup_address = ''
        if $scope.project.location.address && $scope.project.location.address.street_address
            lookup_address+=$scope.project.location.address.street_address
        if $scope.project.location.address.country
            lookup_address+=', '
            lookup_address+=$scope.project.location.address.country
        pos_promise = geolocation.lookupAddress(lookup_address).then((coords)->
            console.log(" found position !", coords)
            marker = 
                    lat: coords[0]
                    lng: coords[1]
            $scope.markers = [marker]
            # centre la carte sur le marker
            $scope.center = {
                lat: coords[0]
                lng: coords[1]
                zoom: 6
            }
        )
)


