package simdat.main;

import simdat.data.RSimDatDataModel;
import simdat.data.RSimDatDataModel.RCellRenderer;

import simdat.SimDat;
import simdat.toolkit.*;
import simdat.wizards.*;

import org.rosuda.deducer.data.ExTable;
import org.rosuda.deducer.data.ExScrollableTable;
//import org.rosuda.deducer.data;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.ArrayList;

import javax.swing.JFrame;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPopupMenu;
import javax.swing.JSeparator;
import javax.swing.JTabbedPane;
import javax.swing.JTable;
import javax.swing.table.JTableHeader;
import javax.swing.table.TableColumnModel;

import org.rosuda.JGR.JGR;
import org.rosuda.JGR.RController;
import org.rosuda.JGR.editor.Editor;
import org.rosuda.JGR.robjects.RObject;
//import org.rosuda.JGR.toolkit.AboutDialog;
import org.rosuda.JGR.util.ErrorMsg;
//import org.rosuda.deducer.Deducer;
import org.rosuda.deducer.data.ColumnHeaderListener;
//import org.rosuda.deducer.data.ColumnHeaderListener.ColumnContextMenu;
//import org.rosuda.deducer.toolkit.LoadData;
//import org.rosuda.deducer.toolkit.SaveData;
import org.rosuda.ibase.Common;
import org.rosuda.ibase.toolkit.EzMenuSwing;

public class DataView extends SimDatMainTab implements ActionListener {

    protected ExTable table;
    protected ExScrollableTable dataScrollPane;
    protected String modelName;

    public DataView(String modelName) {
        super();
        init(modelName);
    }

    protected void init(String modelName) {
        this.modelName = modelName;
        RSimDatDataModel dataModel = new RSimDatDataModel(modelName);
        dataScrollPane = new ExScrollableTable(table = new ExTable(dataModel));
        dataScrollPane.setRowNamesModel(((RSimDatDataModel) dataScrollPane.getExTable().getModel()).getRowNamesModel());
        dataScrollPane.getExTable().setDefaultRenderer(Object.class,
                dataModel.new RCellRenderer());
        table.setColumnListener(new DataViewColumnHeaderListener(table));
        this.setLayout(new BorderLayout());
        this.add(dataScrollPane);
    }

    public void setData(String model) {
        modelName = model;
        RSimDatDataModel dataModel = new RSimDatDataModel(modelName);
        ((RSimDatDataModel) table.getModel()).removeCachedData();
        table.setModel(dataModel);
        dataScrollPane.setRowNamesModel(((RSimDatDataModel) dataScrollPane.getExTable().getModel()).getRowNamesModel());
        dataScrollPane.getExTable().setDefaultRenderer(Object.class,
                dataModel.new RCellRenderer());
    }

    public void refresh() {
        boolean changed = ((RSimDatDataModel) dataScrollPane.getExTable().getModel()).refresh();
        if (changed) {
            dataScrollPane.getRowNamesModel().refresh();
            dataScrollPane.autoAdjustRowWidth();
        }
    }

    public JMenuBar generateMenuBar() {
        JFrame f = new JFrame();
        String[] Menu = {"+", "File",
            "@NNew model", "newmodel",
            "@LOpen model(s)", "loadmodel",
            "@SSave model(s)", "Save Model",
            "@DSave data", "Save Data",
            "@MSave multiple data", "Save Multiple",
            //"-",//"-",
            //"@PPrint","print",
            "~File.Quit",
            "+", "Edit",
            "@CCopy", "copy",
            "@XCut", "cut",
            "@VPaste", "paste",
            "-",
            "Remove Model from Workspace", "Clear Model",
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
            if (cmd == "Open Model") {
                new LoadModel();
            } else if (cmd == "Save Model") {
                new SaveModel(modelName);
            } else if (cmd == "Save Data") {
                new SaveData(modelName);
            } else if (cmd == "Save Multiple") {
                new SaveMultipleData(modelName);
            } else if (cmd == "Clear Model") {
                if (modelName == null) {
                    JOptionPane.showMessageDialog(this, "Invalid selection: There is no model loaded.");
                    return;
                }
                int confirm = JOptionPane.showConfirmDialog(null, "Remove Model "
                        + modelName + " from environment?\n"
                        + "Unsaved changes will be lost.",
                        "Clear Model", JOptionPane.YES_NO_OPTION,
                        JOptionPane.QUESTION_MESSAGE);
                if (confirm == JOptionPane.NO_OPTION) {
                    return;
                }
                SimDat.eval("rm(" + modelName + ")");
                RController.refreshObjects();
            } else if (cmd == "about") {
                new AboutDialog(null);
            } else if (cmd == "cut") {
                table.cutSelection();
            } else if (cmd == "copy") {
                table.copySelection();
            } else if (cmd == "paste") {
                table.pasteSelection();
            } else if (cmd == "print") {
                try {
                    table.print(JTable.PrintMode.NORMAL);
                } catch (Exception exc) {
                }
            } else if (cmd == "editor") {
                new Editor();
            } else if (cmd == "exit") {
                ((JFrame) this.getTopLevelAncestor()).dispose();
            } else if (cmd == "newmodel") {
                String inputValue = JOptionPane.showInputDialog("Model Name: ");
                inputValue = SimDat.getUniqueName(inputValue);
                if (inputValue != null) {
                    SimDat.eval(inputValue.trim() + "<-new(\"SimDatModel\")");
                    RController.refreshObjects();
                    SimDat.refreshModels();
                }
            } else if (cmd == "loadmodel") {
                LoadModel dld = new LoadModel();
            } else if (cmd == "help") {
                SimDat.execute("help.start()");
            } else if (cmd == "table") {
                SimDatMain inst = new SimDatMain();
                inst.setLocationRelativeTo(null);
                inst.setVisible(true);
            } else if (cmd == "savemodel") {
                new SaveModel(modelName);
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
        ((RSimDatDataModel) table.getModel()).removeCachedData();
    }

    public class DataViewColumnHeaderListener extends ColumnHeaderListener {

        private ExTable table;
        private JPopupMenu menu;

        public DataViewColumnHeaderListener(ExTable t) {
            table = t;
            JTableHeader header = table.getTableHeader();
            header.addMouseListener(this);
        }

        public void remove() {
            table.getTableHeader().removeMouseListener(this);
        }

        public void mouseClicked(MouseEvent evt) {
            boolean isMac = System.getProperty("java.vendor").indexOf("Apple") > -1;
            TableColumnModel colModel = table.getColumnModel();
            int vColIndex = colModel.getColumnIndexAtX(evt.getX());
            int mColIndex = table.convertColumnIndexToModel(vColIndex);
            table.selectColumn(vColIndex);

            if (evt.getButton() == MouseEvent.BUTTON3 && !isMac) {
                new ColumnContextMenu(evt);
            }
        }

        public void mousePressed(MouseEvent evt) {
            boolean isMac = System.getProperty("java.vendor").indexOf("Apple") > -1;
            if (evt.isPopupTrigger() && isMac) {
                new ColumnContextMenu(evt);
            }
        }

        /**
         * The popup menu for column headers.
         *
         * @author ifellows
         *
         */
        public class ColumnContextMenu implements ActionListener {

            int vColIndex, mColIndex;

            public ColumnContextMenu(MouseEvent evt) {
                TableColumnModel colModel = table.getColumnModel();
                vColIndex = colModel.getColumnIndexAtX(evt.getX());
                mColIndex = table.convertColumnIndexToModel(vColIndex);
                menu = new JPopupMenu();
                table.getTableHeader().add(menu);

                JMenuItem sortItem = new JMenuItem("Sort (Increasing)");
                sortItem.addActionListener(this);
                menu.add(sortItem);
                sortItem = new JMenuItem("Sort (Decreasing)");
                sortItem.addActionListener(this);
                menu.add(sortItem);
                menu.add(new JSeparator());
                JMenuItem copyItem = new JMenuItem("Copy");
                copyItem.addActionListener(this);
                menu.add(copyItem);
                JMenuItem cutItem = new JMenuItem("Cut");
                cutItem.addActionListener(this);
                menu.add(cutItem);
                JMenuItem pasteItem = new JMenuItem("Paste");
                pasteItem.addActionListener(this);
                menu.add(pasteItem);
                menu.addSeparator();
                JMenuItem insertItem = new JMenuItem("Insert");
                insertItem.addActionListener(this);
                menu.add(insertItem);
                JMenuItem insertNewItem = new JMenuItem("Insert New Column");
                insertNewItem.addActionListener(this);
                menu.add(insertNewItem);
                JMenuItem removeItem = new JMenuItem("Remove Column");
                removeItem.addActionListener(this);
                menu.add(removeItem);

                menu.show(evt.getComponent(), evt.getX(), evt.getY());
            }

            public void actionPerformed(ActionEvent e) {

                JMenuItem source = (JMenuItem) (e.getSource());
                if (source.getText() == "Copy") {
                    table.getCopyPasteAdapter().copy();
                } else if (source.getText() == "Cut") {
                    table.cutColumn(vColIndex);
                } else if (source.getText() == "Paste") {
                    table.getCopyPasteAdapter().paste();
                } else if (source.getText() == "Insert") {
                    table.insertColumn(vColIndex);
                } else if (source.getText() == "Insert New Column") {
                    table.insertNewColumn(vColIndex);
                } else if (source.getText() == "Remove Column") {
                    table.removeColumn(vColIndex);
                } else if (source.getText().equals("Sort (Increasing)")) {
                    String cmd = modelName + " <- sort(" + modelName + ", by=~"
                            + table.getColumnName(vColIndex).trim() + ")";
                    SimDat.eval(cmd);
                    refresh();
                } else if (source.getText().equals("Sort (Decreasing)")) {
                    String cmd = modelName + " <- sort(" + modelName + ", by=~ -"
                            + table.getColumnName(vColIndex).trim() + ")";
                    SimDat.eval(cmd);
                    refresh();
                }
                menu.setVisible(false);
            }
        }
    }
}
