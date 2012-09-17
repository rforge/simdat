package simdat.main;

import simdat.SimDat;
import simdat.toolkit.*;
//import org.rosuda.deducer.data;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.DefaultComboBoxModel;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

import org.rosuda.JGR.DataLoader;
import org.rosuda.JGR.util.ErrorMsg;
import org.rosuda.deducer.Deducer;
import org.rosuda.deducer.toolkit.HelpButton;
import org.rosuda.deducer.toolkit.IconButton;
import org.rosuda.ibase.toolkit.EzMenuSwing;

import simdat.wizards.*;

public class SimDatMainController {

    private static ArrayList dataWindows;
    private static Map tabFactories;
    private static boolean started = false;
    private static JPanel panel;
    private static boolean saveButton;
    private static boolean openButton;
    private static boolean clearButton;

    public static void init() {
        if (!started) {
            dataWindows = new ArrayList();
            tabFactories = new LinkedHashMap();
            addTabFactory("Data", new DataViewFactory());
            addTabFactory("Variables", new VariableViewFactory());
            addTabFactory("Variable Models", new ModelViewFactory());
            addTabFactory("Model Summary", new SummaryViewFactory());

            saveButton = true;
            openButton = true;
            clearButton = true;

            panel = new JPanel();
            GridBagLayout panelLayout = new GridBagLayout();
            panelLayout.rowWeights = new double[]{0.1, 0.1, 0.25, 0.1, 0.1};
            panel.setLayout(panelLayout);
            ActionListener lis = new ActionListener() {

                public void actionPerformed(ActionEvent e) {
                    String cmd = e.getActionCommand();
                    if (cmd == "Open Model") {
                        new ModelLoader();
                    } else if (cmd == "New Model") {
                        String inputValue = JOptionPane.showInputDialog("Model Name: ");
                        if (inputValue != null) {
                            SimDat.eval(inputValue.trim() + "<-new(\"SimDatModel\",name=\"" + inputValue.trim() + "\")");
                        }
                    } else if (cmd == "ANOVA Wizard") {
                        NewOrExistingModel nw = new NewOrExistingModel();
                        int ret = -10;
                        if (nw.Outcome() == 2) {
                            // new model
                            AnovaWizard aov = new AnovaWizard(nw.ModelName(), true);
                            ret = aov.showModalDialog();
                            SimDat.refreshModels();
                            SimDat.setRecentModel(nw.ModelName());
                        }
                        if (nw.Outcome() == 1) {
                            // existing model
                            AnovaWizard aov = new AnovaWizard(nw.ModelName(), false);
                            ret = aov.showModalDialog();
                        }
                    } else if (cmd
                            == "GLM Wizard") {
                        NewOrExistingModel nw = new NewOrExistingModel();
                        int ret = -10;
                        if (nw.Outcome() == 2) {
                            // new model
                            GlmWizard glm = new GlmWizard(nw.ModelName(), true);
                            ret = glm.showModalDialog();
                            SimDat.refreshModels();
                            SimDat.setRecentModel(nw.ModelName());

                            //SimDatMain.setModel(nw.ModelName());
                        }
                        if (nw.Outcome() == 1) {
                            // existing model
                            GlmWizard glm = new GlmWizard(nw.ModelName(), false);
                            ret = glm.showModalDialog();
                        }
                    } else if (cmd
                            == "Regression Wizard") {
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
                    } else if (cmd
                            == "Repeated Measures Wizard") {
                        NewOrExistingModel nw = new NewOrExistingModel();
                        int ret = -10;
                        if (nw.Outcome() == 2) {
                            // new model
                            RmAnovaWizard rm = new RmAnovaWizard(nw.ModelName(), true);
                            ret = rm.showModalDialog();
                            SimDat.refreshModels();
                            //SimDatMain.setModel(nw.ModelName());
                        } else if (nw.Outcome() == 1) {
                            // existing model
                            RmAnovaWizard rm = new RmAnovaWizard(nw.ModelName(), false);
                            ret = rm.showModalDialog();
                        }

                        /*else if(cmd=="tutorial"){
                        HelpButton.showInBrowser("http://www.youtube.com/user/MrIanfellows#p/u/5/iZ857h2j6wA");
                        }else if(cmd=="wiki"){
                        HelpButton.showInBrowser("http://www.deducer.org/manual.html");
                        } */
                    }
                }
            };


            WizardComboBox wizBox = new WizardComboBox();
            panel.add(wizBox, new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0,
                    GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));

            JButton newButton = new IconButton("/icons/newdata_128.png", "New Model", lis, "New Model");
            newButton.setPreferredSize(new java.awt.Dimension(128, 128));
            panel.add(newButton, new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0,
                    GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));

            IconButton openButton = new IconButton("/icons/opendata_128.png", "Open Model", lis, "Open Model");
            openButton.setPreferredSize(new java.awt.Dimension(128, 128));
            panel.add(openButton, new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0,
                    GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));

            /*
            IconButton vidButton = new IconButton("/icons/video_128.png","Online Tutorial Video",lis,"tutorial");
            vidButton.setPreferredSize(new java.awt.Dimension(128,128));
            panel.add(vidButton, new GridBagConstraints(0, 2, 1,1,  0.0, 0.0,
            GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
             */



            IconButton manButton = new IconButton("/icons/info_128.png", "Online Manual", lis, "wiki");
            manButton.setPreferredSize(new java.awt.Dimension(128, 128));
            panel.add(manButton, new GridBagConstraints(0, 3, 1, 1, 0.0, 0.0,
                    GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));

            started = true;
        }
    }

    public static void addViewerWindow(SimDatMain v) {
        dataWindows.add(0, v);
    }

    public static ArrayList getViewerWindows() {
        return dataWindows;
    }

    public static void removeViewerWindow(SimDatMain v) {
        dataWindows.remove(v);
    }

    public static void addTabFactory(String name, SimDatMainTabFactory t) {
        tabFactories.put(name, t);
        for (int i = 0; i < dataWindows.size(); i++) {
            SimDatMain dv = (SimDatMain) dataWindows.get(i);
            String models = dv.getModels();
            dv.reloadTabs(models);
        }
    }

    public static void removeTabFactory(String name) {
        tabFactories.remove(name);
        for (int i = 0; i < dataWindows.size(); i++) {
            SimDatMain dv = (SimDatMain) dataWindows.get(i);
            String models = dv.getModels();
            dv.reloadTabs(models);
        }
    }

    public static String[] getTabNames() {
        Object[] o = tabFactories.keySet().toArray();
        String[] tn = new String[o.length];
        for (int i = 0; i < o.length; i++) {
            tn[i] = (String) o[i];
        }
        return tn;
    }

    public static SimDatMainTab generateTab(String tabName, String dataName) {
        SimDatMainTabFactory factory = (SimDatMainTabFactory) tabFactories.get(tabName);
        if (factory == null) {
            new ErrorMsg("Unknown SimDatMainTabFactory: " + tabName);
            return null;
        }
        return factory.makeViewerTab(dataName);
    }

    public static JPanel getDefaultPanel() {
        return panel;
    }

    public static void setDefaultPanel(JPanel p) {
        panel = p;
    }

    public static boolean showSaveDataButton() {
        return saveButton;
    }

    public static boolean showOpenDataButton() {
        return openButton;
    }

    public static boolean showClearDataButton() {
        return clearButton;
    }

    public static void setSaveDataVisible(boolean show) {
        saveButton = show;
    }

    public static void setOpenDataVisible(boolean show) {
        openButton = show;
    }

    public static void setClearDataVisible(boolean show) {
        clearButton = show;
    }

    public static void addNewModel(String model) {
        SimDat.refreshModels();
        SimDat.setRecentModel(model);
        //panel.refresh();
    }
}

class WizardComboBox extends javax.swing.JComboBox {

    DefaultComboBoxModel model = new DefaultComboBoxModel();
    ItemListener listener;

    WizardComboBox() {
        model.addElement("ANOVA");
        model.addElement("GLM");
        model.addElement("Regression");
        model.addElement("Repeated measures ANOVA");

        this.setModel(model);

        listener = new ItemListener() {

            public void itemStateChanged(ItemEvent e) {
                //String bobo = JOptionPane.showInputDialog("Model Name: ");
                String source = (e.getItem()).toString();
                if (source == "ANOVA") {
                    String modelName = JOptionPane.showInputDialog("Model Name: ");
                    if (modelName != null) {
                        AnovaWizard aov = new AnovaWizard(modelName, true);
                        aov.showModalDialog();
                        SimDat.refreshModels();
                        SimDat.setRecentModel(modelName);
                    }
                } else if (source == "GLM") {
                    String modelName = JOptionPane.showInputDialog("Model Name: ");
                    if (modelName != null) {
                        GlmWizard aov = new GlmWizard(modelName, true);
                        aov.showModalDialog();
                        SimDat.refreshModels();
                        SimDat.setRecentModel(modelName);
                    }
                } else if (source == "Regression") {
                    String modelName = JOptionPane.showInputDialog("Model Name: ");
                    if (modelName != null) {
                        RegressionWizard aov = new RegressionWizard(modelName, true);
                        aov.showModalDialog();
                        SimDat.refreshModels();
                        SimDat.setRecentModel(modelName);
                    }
                } else if (source == "Repeated measures ANOVA") {
                    String modelName = JOptionPane.showInputDialog("Model Name: ");
                    if (modelName != null) {
                        RmAnovaWizard aov = new RmAnovaWizard(modelName, true);
                        aov.showModalDialog();
                        SimDat.refreshModels();
                        SimDat.setRecentModel(modelName);
                    }
                }
            }
        };
        
    this.addItemListener(listener);

        //addItemListener(this);

    }
    
    /*
    public void actionPerformed(ActionEvent arg0) {
        String cmd = arg0.getActionCommand();
        //SimDat.setRecentModel(((RObject) this.getSelectedItem()).getName());
    }
     * 
     */
}