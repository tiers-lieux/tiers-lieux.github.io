module = angular.module("map.controllers", [])

module.run(['$anchorScroll', ($anchorScroll) ->
  $anchorScroll.yOffset = 50
])

module.controller("ImaginationProjectsMapCtrl", ($scope, $anchorScroll, $location, leafletData, leafletEvents, geocoderService, Project, ProjectSheet) ->
    """
    This controller is made to be child of ProjectListCtrl where it watches for update in $scope.projectsheets list
    Upon update, it rebuilds its marker base
    """
    $scope.gotoAnchor = (x) ->
        newHash = 'anchor' + x
        if $location.hash() != newHash
            $location.hash('anchor' + x)
        else
            $anchorScroll()

    console.log("loadind map, projectsheets ?", $scope.projectsheets)

    angular.extend($scope,
        defaults :
            scrollWheelZoom: false # Keep the scrolling working on the page, not in the map
            maxZoom: 14
            minZoom: 1
            path:
                weight: 10
                color: '#800000'
                opacity: 1
        center:
            lat: 46.43
            lng: 2.35
            zoom: 5
        markers : []
    )

    # Watch for update in projectsheets
    $scope.$watch(
            ()->
                return $scope.projectsheets
            ,(newVal, oldVal) ->
                if newVal != oldVal
                    #console.log(" Updating projectsheets : new ="+newVal+" old = "+oldVal)
                    $scope.markers = new Array()
                    angular.forEach($scope.projectsheets, (ps)->
                        # Either get LatLng directly, or from address_locality ?
                        marker = 
                        {
                                lat: ps.project.location.geo.coordinates[1]
                                lng: ps.project.location.geo.coordinates[0]
                                message: '<div ng-include="\'/views/map/marker_card.html\'"></div>'
                                data:
                                        title: ps.project.title
                                        baseline: ps.project.baseline
                                        description: ps.project.description
                                        cover: ps.cover
                                        id: ps.project.id
                                        slug: ps.project.slug

                                icon:
                                        type: 'awesomeMarker'
                                        prefix: 'fa'
                                        # icon: marker.category.icon_name
                                        markerColor: "blue"
                                        iconColor: "white"
                        }
                        console.log("adding marker : ", marker)
                        $scope.markers.push(marker)
                        )

    )

#project: Objectbaseline: "Incroyables comestibles"begin_date: nullcreated_on: "2014-12-09T00:00:00"description: ""end_date: nullid: 244location: Objectgeo: Objectcoordinates: Array[2]0: -2.9837671: 47.666491length: 2__proto__: Array[0]type: "Point"

    # MakerScienceProfile.getList({location__isnull : false}).then((profileResults) ->
    #     angular.forEach(profileResults, (profile) ->
    #         geocoderService.getLatLong(profile.location.address_locality).then((latlng)->
    #             icon =
    #                 iconUrl: gravatarImageService.getImageSrc(profile.parent.user.email, 30, null, 'mm')
    #                 shadowUrl: 'img/users/user-shadow.png'
    #                 iconSize: [30, 30]
    #                 shadowSize:   [44, 44]
    #                 iconAnchor:   [15, 15]
    #                 shadowAnchor: [22, 22]

    #             $scope.markers[profile.id]=
    #                 group: "center"
    #                 groupOption :
    #                     showCoverageOnHover : false
    #                 lat: latlng.lat()
    #                 lng: latlng.lng()
    #                 draggable: false
    #                 icon: icon
    #                 icon_standard : icon
    #                 icon_hover:
    #                     iconUrl: gravatarImageService.getImageSrc(profile.parent.user.email, 52, null, 'mm')
    #                     shadowUrl: 'img/users/user-shadow.png'
    #                     iconSize: [52, 51]
    #                     shadowSize:   [67, 67]
    #                     iconAnchor:   [25, 25]
    #                     shadowAnchor: [33, 33]
    #         )
    #     )
    # )
    # $scope.$on('leafletDirectiveMarker.click', (event, args) ->
    #     marker = $scope.markers[args.markerName]
    #     marker.icon = marker.icon_hover

    #     MakerScienceProfile.one(args.markerName).get().then((profileResult)->
    #         $scope.spottedProfile = profileResult
    #         $scope.spottedProfile.projects = []

    #         ObjectProfileLink.getList({content_type:'project', profile__id : $scope.spottedProfile.parent.id}).then((linkedProjectResults)->
    #             angular.forEach(linkedProjectResults, (linkedProject) ->
    #                 MakerScienceProject.one().get({parent__id : linkedProject.object_id}).then((makerscienceProjectResults) ->
    #                     if makerscienceProjectResults.objects.length == 1
    #                         $scope.spottedProfile.projects.push(makerscienceProjectResults.objects[0])
    #                 )
    #             )
    #         )
    #         $scope.showMemberInfo = true
    #     )
    # )

    # $scope.$on("leafletDirectiveMap.click", (event, args) ->
    #     if $scope.spottedProfile
    #         marker = $scope.markers[$scope.spottedProfile.id]
    #         marker.icon = marker.icon_standard
    #         $scope.spottedProfile = null
    #     $scope.showMemberInfo = false
    # )
)
