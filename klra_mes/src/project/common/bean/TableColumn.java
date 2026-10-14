package project.common.bean;


public class TableColumn {
	private String catalogName;
	private String className;
	private String label;
	private String name;
	private int displaySize;
	private int type;
	private String typeName;	
	public DataMap getMap(){
		DataMap map = new DataMap();
		map.put("catalogName", catalogName);
		map.put("className", className);
		map.put("label", label);
		map.put("name", name);
		map.put("displaySize", displaySize);
		map.put("type", type);
		map.put("typeName", typeName);
		return map;
	}
	public String getCatalogName() {
		return catalogName;
	}
	public void setCatalogName(String catalogName) {
		this.catalogName = catalogName;
	}
	public String getClassName() {
		return className;
	}
	public void setClassName(String className) {
		this.className = className;
	}
	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		this.label = label;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getDisplaySize() {
		return displaySize;
	}
	public void setDisplaySize(int displaySize) {
		this.displaySize = displaySize;
	}
	public int getType() {
		return type;
	}
	public void setType(int type) {
		this.type = type;
	}
	public String getTypeName() {
		return typeName;
	}
	public void setTypeName(String typeName) {
		this.typeName = typeName;
	}
	@Override
	public String toString() {
		return "TableColumn [catalogName=" + catalogName + ", className="
				+ className + ", label=" + label + ", name=" + name
				+ ", displaySize=" + displaySize + ", type=" + type
				+ ", typeName=" + typeName + "]";
	}	
}