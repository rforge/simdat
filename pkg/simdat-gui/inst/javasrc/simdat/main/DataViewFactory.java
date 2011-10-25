package simdat.main;

public class DataViewFactory implements SimDatMainTabFactory{

	public DataViewerTab makeViewerTab(String dataName) {
		return new DataView(dataName);
	}

}
