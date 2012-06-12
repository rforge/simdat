package simdat.main;

public class ModelViewFactory implements SimDatMainTabFactory{

	public SimDatMainTab makeViewerTab(String dataName) {
		return new ModelView(dataName);
	}

}
