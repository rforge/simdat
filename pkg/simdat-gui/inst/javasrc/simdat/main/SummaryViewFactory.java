package simdat.main;

public class SummaryViewFactory implements SimDatMainTabFactory{

	public SimDatMainTab makeViewerTab(String modelName) {
		return new SummaryView(modelName);
	}

}
