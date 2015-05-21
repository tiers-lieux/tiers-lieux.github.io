module = angular.module('commons.base.filters', [])

module.filter('tagNameNotInArray', ->
    return (items, array)-> 
        filtered = _.reject(
            items,
            (item)->
                return _.contains(array, item.name)
        )
        return filtered
)