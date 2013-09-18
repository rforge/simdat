package simdat.toolkit;

import simdat.data.RdfRowEditorModel;
import simdat.data.RdfRowEditorModel.RCellRenderer;

import simdat.SimDat;
//import simdat.toolkit.*;

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
import javax.swing.JPanel;
import javax.swing.table.JTableHeader;
import javax.swing.table.TableColumnModel;

import org.rosuda.JGR.JGR;
import org.rosuda.JGR.RController;
import org.rosuda.JGR.editor.Editor;
import org.rosuda.JGR.robjects.RObject;
import org.rosuda.JGR.toolkit.AboutDialog;
import org.rosuda.JGR.util.ErrorMsg;
//import org.rosuda.deducer.Deducer;
import org.rosuda.deducer.data.ColumnHeaderListener;
//import org.rosuda.deducer.data.ColumnHeaderListener.ColumnContextMenu;
//import org.rosuda.deducer.toolkit.LoadData;
//import org.rosuda.deducer.toolkit.SaveData;
import org.rosuda.ibase.Common;
import org.rosuda.ibase.toolkit.EzMenuSwing;

public class RdfRowEditor extends JPanel implements ActionListener {

    protected ExTable table;
    protected ExScrollableTable dataScrollPane;
    protected String dataName;
    protected String curEnv = SimDat.guiEnv;

    public RdfRowEditor(String dataName, String curEnv) {
        super();
        this.curEnv = curEnv;
        init(dataName);
    }
    public RdfRowEditor(String dataName) {
        super();
        init(dataName);
    }

    protected void init(String dataName) {
        this.dataName = dataName;
        RdfRowEditorModel dataModel = new RdfRowEditorModel(dataName,curEnv);
        dataScrollPane = new ExScrollableTable(table = new ExTable(dataModel));
        dataScrollPane.setRowNamesModel(((RdfRowEditorModel) dataScrollPane.getExTable().getModel()).getRowNamesModel());
        dataScrollPane.getExTable().setDefaultRenderer(Object.class,
                dataModel.new RCellRenderer());
        table.setColumnListener(new DataViewColumnHeaderListener(table));
        this.setLayout(new BorderLayout());
        this.add(dataScrollPane);
    }

    public void setData(String data) {
        dataName = data;
        RdfRowEditorModel dataModel = new RdfRowEditorModel(dataName,curEnv);
        ((RdfRowEditorModel) table.getModel()).removeCachedData();
        table.setModel(dataModel);
        dataScrollPane.setRowNamesModel(((RdfRowEditorModel) dataScrollPane.getExTable().getModel()).getRowNamesModel());
        dataScrollPane.getExTable().setDefaultRenderer(Object.class,
                dataModel.new RCellRenderer());
    }

    public void setData(String data, String curEnv) {
        this.curEnv = curEnv;
        dataName = data;
        RdfRowEditorModel dataModel = new RdfRowEditorModel(dataName,curEnv);
        ((RdfRowEditorModel) table.getModel()).removeCachedData();
        table.setModel(dataModel);
        dataScrollPane.setRowNamesModel(((RdfRowEditorModel) dataScrollPane.getExTable().getModel()).getRowNamesModel());
        dataScrollPane.getExTable().setDefaultRenderer(Object.class,
                dataModel.new RCellRenderer());
    }

    public void refresh() {
        boolean changed = ((RdfRowEditorModel) dataScrollPane.getExTable().getModel()).refresh();
        if (changed) {
            dataScrollPane.getRowNamesModel().refresh();
            dataScrollPane.autoAdjustRowWidth();
        }
    }

    public void actionPerformed(ActionEvent e) {
        //JGR.R.eval("print('"+e.getActionCommand()+"')");
        try {
            String cmd = e.getActionCommand();
            if (cmd == "cut") {
                table.cutSelection();
            } else if (cmd == "copy") {
                table.copySelection();
            } else if (cmd == "paste") {
                table.pasteSelection();
            }
        } catch (Exception e2) {
            new ErrorMsg(e2);
        }
    }

    public void cleanUp() {
        ((RdfRowEditorModel) table.getModel()).removeCachedData();
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
                //menu.addSeparator();
                //JMenuItem insertItem = new JMenuItem ("Insert");
                //insertItem.addActionListener(this);
                //menu.add( insertItem );
                //JMenuItem insertNewItem = new JMenuItem ("Insert New Column");
                //insertNewItem.addActionListener(this);
                //menu.add( insertNewItem );
                //JMenuItem removeItem = new JMenuItem ("Remove Column");
                //removeItem.addActionListener(this);
                //menu.add( removeItem );

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
                    //} else if(source.getText()=="Insert"){
                    //	table.insertColumn(vColIndex);
                    //} else if(source.getText()=="Insert New Column"){
                    //	table.insertNewColumn(vColIndex);
                    //} else if(source.getText()=="Remove Column"){
                    //	table.removeColumn(vColIndex);
                } else if (source.getText().equals("Sort (Increasing)")) {
                    String cmd = dataName + " <- sort(" + dataName + ", by=~"
                            + table.getColumnName(vColIndex).trim() + ")";
                    SimDat.eval(cmd,curEnv);
                    refresh();
                } else if (source.getText().equals("Sort (Decreasing)")) {
                    String cmd = dataName + " <- sort(" + dataName + ", by=~ -"
                            + table.getColumnName(vColIndex).trim() + ")";
                    SimDat.eval(cmd,curEnv);
                    refresh();
                }
                menu.setVisible(false);
            }
        }
    }
}
