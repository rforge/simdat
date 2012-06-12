package simdat.main;

//import org.rosuda.SimDat.data;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ComponentEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.util.ArrayList;
import java.util.Vector;

import javax.swing.DefaultComboBoxModel;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JMenuBar;
import javax.swing.JButton;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.JTabbedPane;
import javax.swing.SwingConstants;
import javax.swing.WindowConstants;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.plaf.basic.BasicComboBoxRenderer;

import org.rosuda.JGR.JGR;
import org.rosuda.JGR.RController;
import org.rosuda.JGR.layout.AnchorConstraint;
import org.rosuda.JGR.layout.AnchorLayout;
import org.rosuda.JGR.robjects.RObject;
import org.rosuda.JGR.util.ErrorMsg;
import org.rosuda.REngine.REXP;
// import org.rosuda.SimDat.SimDat;
import org.rosuda.deducer.toolkit.IconButton;
// import org.rosuda.SimDat.toolkit.LoadData;
// import org.rosuda.SimDat.toolkit.SaveData;
import org.rosuda.ibase.Common;
import org.rosuda.ibase.toolkit.EzMenuSwing;
import org.rosuda.ibase.toolkit.TJFrame;

import simdat.SimDat;
import simdat.toolkit.*;

public class SimDatMain extends TJFrame implements ActionListener{
	private JTabbedPane tabbedPane;
	private JPanel modelSelectorPanel;
	private IconButton saveButton;
	private IconButton openButton;
        private IconButton simulateButton;
        private IconButton saveDataButton;
        private IconButton saveMultipleDataButton;
	private IconButton removeButton;
	private ModelList modelSelector;
	private ArrayList tabs = new ArrayList();
	private String modelName;
	
	public SimDatMain() {
		super("SimDat", false, TJFrame.clsPackageUtil);
		try {
			SimDatMainController.init();
			initGUI();
			SimDatMainController.addViewerWindow(this);
			RObject robj = (RObject)modelSelector.getSelectedItem();
			String model = null;
			if(robj != null)
				model = robj.getName();
			modelName = model;
			reloadTabs(model);
		} catch(Exception e){
			reloadTabs(null);
			e.printStackTrace();
		}
		new Thread(new Refresher(this)).start();
	}
	
	
	private void initGUI() {
		try {
			this.setName("SimDat");
			RController.refreshObjects();
			
			BorderLayout thisLayout = new BorderLayout();
			getContentPane().setLayout(thisLayout);
			setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
			this.setMinimumSize(new java.awt.Dimension(400, 400));

			{
				modelSelectorPanel = new JPanel();
				getContentPane().add(modelSelectorPanel, BorderLayout.NORTH);
				AnchorLayout modelSelectorPanelLayout = new AnchorLayout();
				modelSelectorPanel.setLayout(modelSelectorPanelLayout);
				modelSelectorPanel.setPreferredSize(new java.awt.Dimension(839, 52));
				modelSelectorPanel.setSize(10, 10);
				modelSelectorPanel.setMinimumSize(new java.awt.Dimension(100, 100));
                                {
					simulateButton = new IconButton("/icons/refresh22.png","Simulate",this,"Simulate Model");
					if(SimDatMainController.showOpenDataButton())
						modelSelectorPanel.add(simulateButton, new AnchorConstraint(12, 60, 805, 12,
							AnchorConstraint.ANCHOR_ABS, AnchorConstraint.ANCHOR_NONE,
							AnchorConstraint.ANCHOR_NONE, AnchorConstraint.ANCHOR_ABS));
					simulateButton.setPreferredSize(new java.awt.Dimension(22,22));
				}
				{
					saveDataButton = new IconButton("/icons/floppy22.png","Save Data",this,"Export Data");
					if(SimDatMainController.showSaveDataButton())
						modelSelectorPanel.add(saveDataButton, new AnchorConstraint(12, 60, 805, 62,
										AnchorConstraint.ANCHOR_ABS, AnchorConstraint.ANCHOR_NONE, 
										AnchorConstraint.ANCHOR_NONE, AnchorConstraint.ANCHOR_ABS));
					saveDataButton.setFont(new java.awt.Font("Dialog",0,8));
					saveDataButton.setPreferredSize(new java.awt.Dimension(22,22));
					
				
				}
				{
					JSeparator separator2 = new JSeparator();
					modelSelectorPanel.add(separator2, new AnchorConstraint(-76, 620, 1008, 608, 
										AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL, 
										AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL));
					separator2.setPreferredSize(new java.awt.Dimension(10, 64));
					separator2.setOrientation(SwingConstants.VERTICAL);
				}
				{
					JSeparator separator1 = new JSeparator();
					modelSelectorPanel.add(separator1, new AnchorConstraint(8, 415, 1076, 402, 
										AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL, 
										AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL));
					separator1.setPreferredSize(new java.awt.Dimension(11, 63));
					separator1.setOrientation(SwingConstants.VERTICAL);
				}
				{
					JLabel modelSelectorLabel = new JLabel();
					modelSelectorPanel.add(modelSelectorLabel, new AnchorConstraint(48, 595, 432, 415, 
							AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL, 
							AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL));
					modelSelectorLabel.setText("Model");
					modelSelectorLabel.setPreferredSize(new java.awt.Dimension(151, 20));
					modelSelectorLabel.setFont(new java.awt.Font("Dialog",0,14));
					modelSelectorLabel.setHorizontalAlignment(SwingConstants.CENTER);
					modelSelectorLabel.setHorizontalTextPosition(SwingConstants.CENTER);
				}
                                /*
				{
					ModelComboBoxModel modelSelectorModel = //new DataFrameComboBoxModel();
						new ModelComboBoxModel(SimDat.MODELS); // TODO: search for models
					BasicComboBoxRenderer modelSelectorRenderer = new BasicComboBoxRenderer(){
						public Component getListCellRendererComponent(JList list, Object value, 
								int index, boolean isSelected, boolean cellHasFocus){
							return super.getListCellRendererComponent(list, value==null ? null : ((RObject)value).getName(), index, isSelected, cellHasFocus);
						}
					};
					modelSelector = new JComboBox();
					modelSelectorPanel.add(modelSelector, new AnchorConstraint(432, 594, 906, 415, 
							AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL, 
							AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL));
					modelSelector.setModel(modelSelectorModel);
					modelSelector.setRenderer(modelSelectorRenderer);
					modelSelector.setPreferredSize(new java.awt.Dimension(149, 28));
					modelSelector.addActionListener(this);
				}
                                 *
                                 */
                            {
                                    modelSelector = new ModelList();
                                    modelSelector.addActionListener(this);
                                    modelSelectorPanel.add(modelSelector, new AnchorConstraint(432, 594, 906, 415,
							AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL,
							AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL));
                            }
				{
					removeButton = new IconButton("/icons/trash22.png","Remove from Workspace",
							this,"Clear Data");
					if(SimDatMainController.showClearDataButton())
						modelSelectorPanel.add(removeButton, new AnchorConstraint(144, 12, 971, 863, 
							AnchorConstraint.ANCHOR_NONE, AnchorConstraint.ANCHOR_ABS, 
							AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_NONE));
					removeButton.setPreferredSize(new java.awt.Dimension(22,22));
				}
			}
			
			{
				tabbedPane = new JTabbedPane();
				getContentPane().add(tabbedPane, BorderLayout.CENTER);
				tabbedPane.setPreferredSize(new java.awt.Dimension(839, 395));
				tabbedPane.setTabPlacement(JTabbedPane.LEFT);
			}
			
			if(!Common.isMac()){
				tabbedPane.setTabPlacement(JTabbedPane.TOP);
			}
			
			pack();
			int mw = Toolkit.getDefaultToolkit().getScreenSize().width-100;
			int mh = Toolkit.getDefaultToolkit().getScreenSize().height-50;
			this.setSize(Math.min(839,mw), Math.min(839,mh));
			
			final JFrame theFrame = this;
			this.addComponentListener(new java.awt.event.ComponentAdapter() {
				  public void componentResized(ComponentEvent event) {
					  theFrame.setSize(
				      Math.max(300, theFrame.getWidth()),
				      theFrame.getHeight());
				  }
			});
			

			tabbedPane.addChangeListener(new ChangeListener(){
				public void stateChanged(ChangeEvent changeEvent) {
					Component comp = tabbedPane.getSelectedComponent();
					if(comp instanceof simdat.main.SimDatMainTab){
						SimDatMainTab dvt = (SimDatMainTab) comp;
						setJMenuBar(dvt.generateMenuBar());
					}
				}
			});
			
			this.addWindowListener(new WindowAdapter(){
				public void windowClosed(WindowEvent arg0) {
					SimDatMainController.removeViewerWindow(SimDatMain.this);
					cleanUp();
				}
				
			});

		} catch (Exception e) {
			new ErrorMsg(e);
		}
	}

	public void reloadTabs(String model){
		cleanUp();
		if(model==null){
			modelName=null;
			JPanel p = SimDatMainController.getDefaultPanel();
			tabbedPane.removeAll();
			tabs.clear();
			tabbedPane.addTab("Get Started", p);
			return;
		}
		try {
			modelName=model;
			String[] tabNames = SimDatMainController.getTabNames();
			tabbedPane.removeAll();
			tabs.clear();
			for(int i=0; i<tabNames.length; i++){
				SimDatMainTab t = SimDatMainController.generateTab(tabNames[i], model);
				tabs.add(t);
				tabbedPane.addTab(tabNames[i], t);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public void setModel(String model){
		if(tabs.size()==0){
			reloadTabs(model);
			return;
		}
		modelName=model;
		//System.out.println("Setting data: " +data);
		for(int i=0; i < tabs.size(); i++){
			SimDatMainTab t = (SimDatMainTab) tabs.get(i);
			t.setData(model);
                        t.refresh();
		}
	}
	
	public String getModels(){return modelName;}

	public void cleanUp(){
		for(int i=0; i < tabs.size(); i++){
			SimDatMainTab t = (SimDatMainTab) tabs.get(i);
			t.cleanUp();
		}
	}
	
	public void actionPerformed(ActionEvent e) {
		try{
			String cmd = e.getActionCommand();
			if(cmd.equals("comboBoxChanged") ){
				String data = ((RObject)modelSelector.getSelectedItem()).getName();
				if(data == null || data == "")
					return;
				if(!data.equals(modelName)){
					setModel(data);
					SimDat.setRecentModel(modelName);
				}
				
			} else if(cmd=="Open Model"){
				new LoadModel();
			} else if(cmd=="Save Model"){
				new SaveModel(modelName);
			} else if(cmd=="Export Data"){
				new SaveData(modelName);
			} else if(cmd=="Clear Model"){
				if(modelSelector.getSelectedItem()==null){
					JOptionPane.showMessageDialog(this, "Invalid selection: There is no model loaded.");
					return;
				}
				String model = ((RObject)modelSelector.getSelectedItem()).getName();
				int confirm = JOptionPane.showConfirmDialog(null, "Remove Model "+
						model+" from enviornment?\n" +
								"Unsaved changes will be lost.",
						"Clear Model", JOptionPane.YES_NO_OPTION,
						JOptionPane.QUESTION_MESSAGE);
				if(confirm == JOptionPane.NO_OPTION)
					return;
				SimDat.execute("rm("+model + ")");
				RController.refreshObjects();
			} else if(cmd=="Simulate Model"){
                            if(modelSelector.getSelectedItem()==null){
					JOptionPane.showMessageDialog(this, "Invalid selection: There is no model loaded.");
					return;
				}
				String model = ((RObject)modelSelector.getSelectedItem()).getName();
                                SimDat.eval(model + " <- simulate(" + model + ")"); // TODO: should be execute
                                RController.refreshObjects();
                                reloadTabs(model);
                        }
		}catch(Exception ex){
			ex.printStackTrace();
		}
	}


	public void refresh() {
                modelSelector.refreshModelNames();
		//((ModelComboBoxModel) modelSelector.getModel()).refresh(SimDat.getModels());
		//if(((RObject)modelSelector.getSelectedItem()) == null && modelName!=null){
                if((modelSelector.getSelectedRObject()) == null && modelName!=null){
			reloadTabs(null);
			return;
		}
		Component t =  tabbedPane.getSelectedComponent();
		if(t instanceof SimDatMainTab)
			((SimDatMainTab)t).refresh();
//		for(int i=0; i < tabs.size(); i++){
//			SimDatMainTab t = (SimDatMainTab) tabs.get(i);
//			t.refresh();
//		}
	}
	
}

class ModelComboBoxModel extends DefaultComboBoxModel{

	private Vector items;
	private int selectedIndex=0;
	
	public Object getElementAt(int index){
		return items.elementAt(index);
	}
	public int getIndexOf(Object anObject){
		for(int i = 0;i<items.size();i++)
			if(items.elementAt(i)==anObject)
				return i;
		return -1;
	}
	public int getSize() {
		return items.size();
	}
	
	public Object getSelectedItem(){
		if(items.size()>0)
			return items.elementAt(selectedIndex);
		else
			return null;
	}
	
	public String getNameAt(int index){
		return ((RObject)items.elementAt(index)).getName();
	}
	
	public void setSelectedItem(Object obj){
		selectedIndex = getIndexOf(obj);
	}
	
	
	public ModelComboBoxModel(Vector v){
		items = new Vector(v);
	}
	public void refresh(Vector v){
		String modelName = null;
		int prevSize = items.size();
		if(getSelectedItem()!=null)
			modelName = ((RObject)getSelectedItem()).getName();
		this.removeAllElements();			
		items = new Vector(v);
		selectedIndex=0;			
		if(items.size()>0){
			for(int i = 0;i<items.size();i++)
				if(((RObject)items.elementAt(i)).getName().equals(modelName))
					selectedIndex =i;
			this.fireContentsChanged(this,0,prevSize);
		}

	}	
	
}

class Refresher implements Runnable {
	final SimDatMain viewer;
	public Refresher(SimDatMain v) {
		viewer=v;
	}

	public void run() {
		boolean cont = true;
		while(cont){
			try {
				Thread.sleep(5000);
				if(viewer==null || !viewer.isDisplayable())
					cont=false;
				else{
					viewer.refresh();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}

