package simdat.main;

import javax.swing.JMenuBar;
import javax.swing.JPanel;

public abstract class SimDatMainTab extends JPanel{
	
	public abstract void setData(String data);
	public abstract void refresh();
	public abstract JMenuBar generateMenuBar();
	public abstract void cleanUp();
}
