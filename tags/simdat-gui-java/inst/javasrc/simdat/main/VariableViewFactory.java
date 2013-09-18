package simdat.main;

public class VariableViewFactory implements SimDatMainTabFactory{

	public SimDatMainTab makeViewerTab(String modelName) {
		return new VariableView(modelName);
	}

}
