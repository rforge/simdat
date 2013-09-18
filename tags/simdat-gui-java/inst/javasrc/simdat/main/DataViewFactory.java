package simdat.main;

public class DataViewFactory implements SimDatMainTabFactory{

	public SimDatMainTab makeViewerTab(String dataName) {
		return new DataView(dataName);
	}

}
