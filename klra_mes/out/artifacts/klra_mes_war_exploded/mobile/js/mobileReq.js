function reqPlantList() {
	var json = netUtil.sendData({
		url : "/mobile/plant/list.data",
	});
	return json;
}