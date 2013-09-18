package simdat.main;

import simdat.SimDat;
import simdat.wizards.*;
import simdat.data.RDataFrameModel;
import simdat.data.RSimDatModelModel;

import org.rosuda.deducer.data.DataViewerTab;
import org.rosuda.deducer.data.ExTable;
import org.rosuda.deducer.data.ExScrollableTable;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.DefaultCellEditor;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JMenuBar;
import javax.swing.JOptionPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.JScrollPane;

import org.rosuda.JGR.RController;
import org.rosuda.JGR.editor.Editor;
import org.rosuda.JGR.toolkit.AboutDialog;
import org.rosuda.JGR.util.ErrorMsg;
import org.rosuda.REngine.REXPLogical;
import org.rosuda.deducer.Deducer;
//import org.rosuda.deducer.data.RDataFrameVariableModel.VariableNumberListModel;
//import org.rosuda.deducer.data.R
import org.rosuda.deducer.toolkit.LoadData;
import org.rosuda.deducer.toolkit.SaveData;
import org.rosuda.deducer.menu.FactorDialog;
import org.rosuda.ibase.Common;
import org.rosuda.ibase.toolkit.EzMenuSwing;

public class SummaryView extends SimDatMainTab implements ActionListener {

	protected String modelName;
        
        protected JTextArea textArea ;
        
        protected JScrollPane summaryScroller; 

	protected ExScrollableTable variableScrollPane;
	protected ExTable ex;
	protected JComboBox scomboBox;
        protected JComboBox tcomboBox;

	public SummaryView(String modelName){
		super();
		init(modelName);
                
	}
	// 0 = name
	// 1 = scale
	// 2 = random
	// 3 = levels
	// 4 = min
	// 5 = max
	// 6 = digits
	private void init(String modelName){
		this.modelName = modelName;

                this.textArea = new JTextArea();
                
                this.summaryScroller = new JScrollPane();
                
                this.summaryScroller.setViewportView(this.textArea);
                this.textArea.setFont(new java.awt.Font("Monospaced", 0, 12));
                this.textArea.setEditable(false);
                
		this.setLayout(new BorderLayout());
		this.add(textArea);
                
                this.setData(this.modelName);
	}

	public void setData(String model) {
		modelName = model;
                
                String[] txt = {};
                try {
                    txt = (SimDat.eval("capture.output(summary(" + this.modelName + "))")).asStrings();
                }
                catch (Exception e) {
			new ErrorMsg(e);
		}
                
                String out = "";
                for(int i = 0;i < txt.length;i++)
                    out += txt[i] + "\n";
                this.textArea.setText(out);
		
	}

	public void refresh() {
            this.setData(this.modelName);
	}

	public JMenuBar generateMenuBar() {
		JFrame f = new JFrame();
		String[] Menu = { "+", "File", "@NNew Data","newdata", "@LOpen Data", "loaddata","@SSave Data", "Save Data", "-",
				 "-","@PPrint","print","~File.Quit",
				"+","Edit","@CCopy","copy","@XCut","cut", "@VPaste","paste","-","Remove Data from Workspace", "Clear Data",
				"~Window",
                                "+", "Wizards",
                                "ANOVA", "ANOVA Wizard",
                                "General Linear Model", "GLM Wizard",
                                "Regression", "Regression Wizard",
                                "Repeated Measures ANOVA", "Repeated Measures Wizard",
                                "+","Help","R Help","help", "~About","0" };
			JMenuBar mb = EzMenuSwing.getEzMenu(f, this, Menu);

			//preference and about for non-mac systems
			if(!Common.isMac()){
				EzMenuSwing.addMenuSeparator(f, "Edit");
				EzMenuSwing.addJMenuItem(f, "Help", "About", "about", this);
				for(int i=0;i<mb.getMenuCount();i++){
					if(mb.getMenu(i).getText().equals("About")){
						mb.remove(i);
						i--;
					}
				}
			}
		return f.getJMenuBar();
	}

	public void actionPerformed(ActionEvent e) {
		//JGR.R.eval("print('"+e.getActionCommand()+"')");
		try{
			String cmd = e.getActionCommand();
			if(cmd=="Open Data"){
				new LoadData();
			}else if(cmd=="Save Data"){

				new SaveData(modelName);
			}else if(cmd=="Clear Data"){
				if(modelName==null){
					JOptionPane.showMessageDialog(this, "Invalid selection: There is no data loaded.");
					return;
				}
				int confirm = JOptionPane.showConfirmDialog(null, "Remove Data Frame "+
						modelName+" from enviornment?\n" +
								"Unsaved changes will be lost.",
						"Clear Data Frame", JOptionPane.YES_NO_OPTION,
						JOptionPane.QUESTION_MESSAGE);
				if(confirm == JOptionPane.NO_OPTION)
					return;
				Deducer.eval("rm("+modelName + ")");
				RController.refreshObjects();
			}else if (cmd == "about")
				new AboutDialog(null);
			else if (cmd == "cut"){
					ex.cutSelection();
			}else if (cmd == "copy") {
					ex.copySelection();
			}else if (cmd == "paste") {
					ex.pasteSelection();
			} else if (cmd == "print"){
				try{
					ex.print(JTable.PrintMode.NORMAL);
				}catch(Exception exc){}
			}else if (cmd == "editor")
				new Editor();
			else if (cmd == "exit")
				((JFrame)this.getTopLevelAncestor()).dispose();
			else if(cmd=="newdata"){
				String inputValue = JOptionPane.showInputDialog("Data Name: ");
				inputValue = Deducer.getUniqueName(inputValue);
				if(inputValue!=null){
					Deducer.eval(inputValue.trim()+"<-data.frame(Var1=NA)");
					RController.refreshObjects();
				}
			}else if (cmd == "loaddata"){
				LoadData dld= new LoadData();
			}else if (cmd == "help")
				Deducer.execute("help.start()");
			else if (cmd == "table"){
				SimDatMain inst = new SimDatMain();
				inst.setLocationRelativeTo(null);
				inst.setVisible(true);
			} else if (cmd == "save") {
				new SaveData(modelName);
                        } else if (cmd == "ANOVA Wizard") {
                NewOrExistingModel nw = new NewOrExistingModel();
                int ret = -10;
                if (nw.Outcome() == 2) {
                    // new model
                    AnovaWizard aov = new AnovaWizard(nw.ModelName(), true);
                    ret = aov.showModalDialog();
                }
                if (nw.Outcome() == 1) {
                    // existing model
                    AnovaWizard aov = new AnovaWizard(nw.ModelName(), false);
                    ret = aov.showModalDialog();
                }
            } else if (cmd == "GLM Wizard") {
                NewOrExistingModel nw = new NewOrExistingModel();
                int ret = -10;
                if (nw.Outcome() == 2) {
                    // new model
                    GlmWizard glm = new GlmWizard(nw.ModelName(), true);
                    ret = glm.showModalDialog();
                }
                if (nw.Outcome() == 1) {
                    // existing model
                    GlmWizard glm = new GlmWizard(nw.ModelName(), false);
                    ret = glm.showModalDialog();
                }
            } else if (cmd == "Regression Wizard") {
                NewOrExistingModel nw = new NewOrExistingModel();
                int ret = -10;
                if (nw.Outcome() == 2) {
                    // new model
                    RegressionWizard glm = new RegressionWizard(nw.ModelName(), true);
                    ret = glm.showModalDialog();
                    SimDat.refreshModels();
                    //SimDatMain.setModel(nw.ModelName());
                }
                if (nw.Outcome() == 1) {
                    // existing model
                    RegressionWizard glm = new RegressionWizard(nw.ModelName(), false);
                    ret = glm.showModalDialog();
                }
            } else if (cmd == "Repeated Measures Wizard") {
                NewOrExistingModel nw = new NewOrExistingModel();
                int ret = -10;
                if (nw.Outcome() == 2) {
                    // new model
                    RmAnovaWizard rm = new RmAnovaWizard(nw.ModelName(), true);
                    ret = rm.showModalDialog();
                } else if (nw.Outcome() == 1) {
                    // existing model
                    RmAnovaWizard rm = new RmAnovaWizard(nw.ModelName(), false);
                    ret = rm.showModalDialog();
                }
            }

		}catch(Exception e2){new ErrorMsg(e2);}
	}

	public void cleanUp() {

	}
}
