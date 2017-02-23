({
	search : function(searchString) {
        var aList = [];
        for(var i = 0; i<10; i++){
        	aList.push(searchString+" "+(Math.random() * (500 - 1) + 1));
        }
        return aList;
	}
})