/* TODO:
variable renaming
adding variable
 */
package simdat.main;

import simdat.SimDat;
import simdat.toolkit.*;
import simdat.wizards.*;
import simdat.data.RSimDatVariableModel;

//import simdat.main.SimDatMainTab;
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

import org.rosuda.JGR.RController;
import org.rosuda.JGR.editor.Editor;
import org.rosuda.JGR.toolkit.AboutDialog;
import org.rosuda.JGR.util.ErrorMsg;
import org.rosuda.REngine.REXPLogical;
//import org.rosuda.deducer.Deducer;
//import org.rosuda.deducer.data.RDataFrameVariableModel.VariableNumberListModel;
//import org.rosuda.deducer.data.RDataFrameVariableModel;
//import org.rosuda.deducer.toolkit.LoadData;
//import org.rosuda.deducer.toolkit.SaveData;
import simdat.toolkit.FactorDialog;
import org.rosuda.ibase.Common;
import org.rosuda.ibase.toolkit.EzMenuSwing;

public class VariableView extends SimDatMainTab implements ActionListener {

    protected String modelName;
    protected ExScrollableTable variableScrollPane;
    protected ExTable ex;
    protected JComboBox scomboBox;
    protected JComboBox tcomboBox;

    public VariableView(String modelName) {
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

    private void init(String modelName) {
        this.modelName = modelName;

        // variable scale
        scomboBox = new JComboBox();
        scomboBox.addItem("Nominal");
        scomboBox.addItem("Ordinal");
        scomboBox.addItem("Interval");
        scomboBox.addItem("Ratio");

        // variable type
        tcomboBox = new JComboBox();
        tcomboBox.addItem("Fixed");
        tcomboBox.addItem("Random");

        RSimDatVariableModel varModel = new RSimDatVariableModel(modelName);
        ex = new ExTable();
        ex.setModel(varModel);
        ex.getColumnModel().getColumn(1).setCellEditor(new DefaultCellEditor(scomboBox));
        ex.getColumnModel().getColumn(2).setCellEditor(new DefaultCellEditor(tcomboBox));
        ex.getColumnModel().getColumn(0).setPreferredWidth(110);
        ex.getColumnModel().getColumn(1).setPreferredWidth(70);
        ex.getColumnModel().getColumn(2).setPreferredWidth(70);
        ex.getColumnModel().getColumn(3).setPreferredWidth(250);
        ex.getColumnModel().getColumn(4).setPreferredWidth(70);
        ex.getColumnModel().getColumn(5).setPreferredWidth(70);
        ex.getColumnModel().getColumn(6).setPreferredWidth(70);
        ex.setColumnSelectionAllowed(true);
        ex.setRowSelectionAllowed(true);
        ex.getTableHeader().removeMouseListener(ex.getColumnListener());
        ex.addMouseListener(new MouseAdapter() {

            public void mouseClicked(MouseEvent e) {
                ExTable extab = (ExTable) e.getSource();
                if (extab.getSelectedColumn() == 3) {
                    int row = extab.getSelectedRow();
                    String varName = (String) extab.getModel().getValueAt(row, 0);
                    String modName = VariableView.this.modelName;
                    REXPLogical tmp;
                    try {
                        tmp = (REXPLogical) SimDat.eval("is.factor(getData(" + modName + ")$" + varName + ")");
                        if (tmp != null && tmp.isTRUE()[0]) {
                            FactorDialog fact = new FactorDialog(null, modName, varName);
                            fact.setLocationRelativeTo(ex);
                            fact.setTitle("Factor Editor: " + varName);
                            fact.setVisible(true);
                        }
                    } catch (Exception exc) {
                    }


                }
            }
        });

        variableScrollPane = new ExScrollableTable(ex);
        variableScrollPane.setRowNamesModel(varModel.new VariableNumberListModel());
        variableScrollPane.displayContextualMenu(false);
        this.setLayout(new BorderLayout());
        this.add(variableScrollPane);
    }

    public void setData(String model) {
        modelName = model;
        RSimDatVariableModel varModel = new RSimDatVariableModel(modelName);
        ex.setModel(varModel);
        ex.getColumnModel().getColumn(1).setCellEditor(new DefaultCellEditor(scomboBox));
        ex.getColumnModel().getColumn(2).setCellEditor(new DefaultCellEditor(tcomboBox));

        ex.getColumnModel().getColumn(0).setPreferredWidth(110);
        ex.getColumnModel().getColumn(1).setPreferredWidth(70);
        ex.getColumnModel().getColumn(2).setPreferredWidth(70);
        ex.getColumnModel().getColumn(3).setPreferredWidth(250);
        ex.getColumnModel().getColumn(4).setPreferredWidth(70);
        ex.getColumnModel().getColumn(5).setPreferredWidth(70);
        ex.getColumnModel().getColumn(6).setPreferredWidth(70);

        variableScrollPane.setRowNamesModel(varModel.new VariableNumberListModel());
    }

    public void refresh() {
        int colStart = -1;
        int colEnd = -1;
        int rowStart = -1;
        int rowEnd = -1;
        int[] cols = ex.getSelectedColumns();
        if (cols.length > 0) {
            colStart = cols[0];
            colEnd = cols[cols.length - 1];
        }
        int[] rows = ex.getSelectedRows();
        if (rows.length > 0) {
            rowStart = rows[0];
            rowEnd = rows[rows.length - 1];
        }
        ((RSimDatVariableModel) variableScrollPane.getExTable().getModel()).refresh();
        variableScrollPane.getRowNamesModel().refresh();
        variableScrollPane.autoAdjustRowWidth();

        if (colStart != -1 && colEnd != -1 && rowStart != -1 && rowEnd != -1) {
            ex.changeSelection(rowStart, colStart, false, false);
            ex.changeSelection(rowEnd, colEnd, false, true);
        }
    }

    public JMenuBar generateMenuBar() {
        JFrame f = new JFrame();
        String[] Menu = {"+", "File", "@NNew Data", "newdata", "@LOpen Data", "loaddata", "@SSave Data", "Save Data", "-",
            "-", "@PPrint", "print", "~File.Quit",
            "+", "Edit", "@CCopy", "copy", "@XCut", "cut", "@VPaste", "paste", "-", "Remove Data from Workspace", "Clear Data",
            "~Window",
            "+", "Wizards",
            "ANOVA", "ANOVA Wizard",
            "General Linear Model", "GLM Wizard",
            "Regression", "Regression Wizard",
            "Repeated Measures ANOVA", "Repeated Measures Wizard",
            "+", "Help", "R Help", "help", "~About", "0"};
        JMenuBar mb = EzMenuSwing.getEzMenu(f, this, Menu);

        //preference and about for non-mac systems
        if (!Common.isMac()) {
            EzMenuSwing.addMenuSeparator(f, "Edit");
            EzMenuSwing.addJMenuItem(f, "Help", "About", "about", this);
            for (int i = 0; i < mb.getMenuCount(); i++) {
                if (mb.getMenu(i).getText().equals("About")) {
                    mb.remove(i);
                    i--;
                }
            }
        }
        return f.getJMenuBar();
    }

    public void actionPerformed(ActionEvent e) {
        //JGR.R.eval("print('"+e.getActionCommand()+"')");
        try {
            String cmd = e.getActionCommand();
            if (cmd.equals("Open Model")) {
                new LoadModel();
            } else if (cmd.equals("Save Model")) {
                new SaveModel(modelName);
            } else if (cmd.equals("Save Data")) {
                new SaveData(modelName);
            } else if (cmd.equals("Clear Data")) {
                if (modelName == null) {
                    JOptionPane.showMessageDialog(this, "Invalid selection: There is no data loaded.");
                    return;
                }
                int confirm = JOptionPane.showConfirmDialog(null, "Remove Data Frame "
                        + modelName + " from enviornment?\n"
                        + "Unsaved changes will be lost.",
                        "Clear Data Frame", JOptionPane.YES_NO_OPTION,
                        JOptionPane.QUESTION_MESSAGE);
                if (confirm == JOptionPane.NO_OPTION) {
                    return;
                }
                SimDat.eval("rm(" + modelName + ")");
                RController.refreshObjects();
            } else if (cmd.equals("about")) {
                new AboutDialog(null);
            } else if (cmd.equals("cut")) {
                ex.cutSelection();
            } else if (cmd.equals("copy")) {
                ex.copySelection();
            } else if (cmd.equals("paste")) {
                ex.pasteSelection();
            } else if (cmd.equals("print")) {
                try {
                    ex.print(JTable.PrintMode.NORMAL);
                } catch (Exception exc) {
                }
            } else if (cmd.equals("editor")) {
                new Editor();
            } else if (cmd.equals("exit")) {
                ((JFrame) this.getTopLevelAncestor()).dispose();
            } else if (cmd.equals("newdata")) {
                String inputValue = JOptionPane.showInputDialog("Data Name: ");
                inputValue = SimDat.getUniqueName(inputValue);
                if (inputValue != null) {
                    SimDat.eval(inputValue.trim() + "<-data.frame(Var1=NA)");
                    RController.refreshObjects();
                }
            } else if (cmd.equals("loadmodel")) {
                LoadModel dld = new LoadModel();
            } else if (cmd.equals("help")) {
                SimDat.execute("help.start()");
            } else if (cmd.equals("table")) {
                SimDatMain inst = new SimDatMain();
                inst.setLocationRelativeTo(null);
                inst.setVisible(true);
            } else if (cmd.equals("save")) {
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

        } catch (Exception e2) {
            new ErrorMsg(e2);
        }
    }

    public void cleanUp() {
    }
}
