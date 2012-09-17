package simdat;

import simdat.main.*;
import simdat.toolkit.*;

//import org.rosuda.deducer.RConnector;
//import org.rosuda.deducer.DefaultRConnector;
//import org.rosuda.deducer.JGRConnector;
import org.rosuda.deducer.WindowTracker;

import java.awt.Event;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
//import java.awt.event.KeyEvent;
//import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.Vector;


import javax.swing.DefaultListModel;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
//import javax.swing.KeyStroke;
import javax.swing.ListModel;
import javax.swing.UIManager;


import org.rosuda.JGR.JGR;
import org.rosuda.JGR.RController;
import org.rosuda.JGR.robjects.RObject;
//import org.rosuda.JGR.toolkit.FileSelector;
import org.rosuda.JGR.toolkit.PrefDialog;
import org.rosuda.JGR.util.ErrorMsg;


//import org.rosuda.deducer.menu.*;
//import org.rosuda.deducer.menu.twosample.TwoSampleDialog;
//import org.rosuda.deducer.models.*;
//import org.rosuda.deducer.plots.*;
//import org.rosuda.deducer.toolkit.DeducerPrefs;
import org.rosuda.deducer.toolkit.HelpButton;
//import org.rosuda.deducer.toolkit.LoadData;
import org.rosuda.deducer.toolkit.PrefPanel;
//import org.rosuda.deducer.toolkit.SaveData;
//import org.rosuda.deducer.toolkit.VariableSelectionDialog;
//import org.rosuda.deducer.data.DataFrameSelector;
//import org.rosuda.deducer.data.DataViewer;

import org.rosuda.REngine.REXPEnvironment;
import org.rosuda.REngine.REXP;
import org.rosuda.REngine.REXPLogical;
import org.rosuda.REngine.REXPMismatchException;
import org.rosuda.REngine.REngine;
import org.rosuda.REngine.REngineException;
import org.rosuda.REngine.JRI.JRIEngine;


import org.rosuda.ibase.Common;
import org.rosuda.ibase.toolkit.EzMenuSwing;

public class SimDat {

    /** Title (used for displaying the splashscreen) */
    public static final String Title = "SimDat";
    /** Subtitle (used for displaying the splashscreen) */
    public static final String Subtitle = "Flexible Data Simulation";
    /** Develtime (used for displaying the splashscreen) */
    public static final String DevelTime = "2011 - 2012";
    /** Organization (used for displaying the splashscreen) */
    public static final String Institution = "University College London";
    /** Author JGR (used for displaying the splashscreen) */
    public static final String Author1 = "Maarten Speekenbrink";
    /** Author JRI, rJava and JavaGD (used for displaying the splashscreen) */
    public static final String AUTHOR2 = "Alastair McClelland";
    /** Author JGR parts since 2009 */
    //public static final String AUTHOR3 = "Ian Fellows";
    /** Website of organization (used for displaying the splashscreen) */
    public static final String Website = "http://www.ucl.ac.uk";
    /** Filename of the splash-image (used for displaying the splashscreen) */
    public static final String Splash = "jgrsplash.jpg";
    ConsoleListener cListener = new ConsoleListener();
    static final int MENUMODIFIER = Common.isMac() ? Event.META_MASK : Event.CTRL_MASK;
    static int menuIndex = 3;
    static String recentActiveModel = "";
    public static final String Version = "0.1-0";
    public static String guiEnv = "simdat.gui.env";
    public static REXPEnvironment guiREnv;
    public static String modelEnv = "simdat.model.env";
    public static boolean insideJGR;
    public static boolean started;
    private static RConnector rConnection = null;
    public static Vector MODELS = new Vector();

    public SimDat(boolean jgr) {
        started = false;
        Common.getScreenRes(); //initializes value if not already set
        try {
            if (jgr && JGR.isJGRmain()) {
                startWithJGR();
                (new Thread() {

                    public void run() {
                        if (SimDatPrefs.VIEWERATSTARTUP) {
                            SimDatMain inst = new SimDatMain();
                            inst.setLocationRelativeTo(null);
                            inst.setVisible(true);
                            JGR.MAINRCONSOLE.toFront();
                        }
                        new Thread(new DataRefresher()).start();
                    }
                }).start();

            }
        } catch (Exception e) {
            new ErrorMsg(e);
        }
    }

    public void startNoJGR() {
        try {

            insideJGR = false;
            String nativeLF = UIManager.getSystemLookAndFeelClassName();
            try {
                UIManager.setLookAndFeel(nativeLF);
            } catch (InstantiationException e) {
            } catch (ClassNotFoundException e) {
            } catch (IllegalAccessException e) {
            }
            org.rosuda.util.Platform.initPlatform("org.rosuda.JGR.toolkit.");

            try {
                rConnection = new DefaultRConnector(new JRIEngine(org.rosuda.JRI.Rengine.getMainEngine()));
            } catch (REngineException e) {
                new ErrorMsg(e);
            }

            SimDatPrefs.initialize();

            started = true;
            eval(".javaGD.set.class.path(\"org/rosuda/JGR/JavaGD\")");
            new Thread(new DataRefresher()).start();
        } catch (Exception e) {
            new ErrorMsg(e);
        }
    }

    public void startWithJGR() {
        insideJGR = true;
        rConnection = new JGRConnector();
        String simDatMenu = "SimDat";
        /* String analysisMenu = "Analysis"; */
        try {
            SimDatPrefs.initialize();
            if (SimDatPrefs.SHOWDATA) {
                insertMenu(JGR.MAINRCONSOLE, simDatMenu, menuIndex);
                EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, simDatMenu, "New Model", "nmodel", cListener);
                EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, simDatMenu, "Load Model", "lmodel", cListener);
                EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, simDatMenu, "Save Model", "smodel", cListener);
                EzMenuSwing.getMenu(JGR.MAINRCONSOLE, simDatMenu).addSeparator();
                EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, simDatMenu, "Load Workspace", "lworkspace", cListener);
                EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, simDatMenu, "Save Workspace", "sworkspace", cListener);
                menuIndex++;
            }
            /*
            if(DeducerPrefs.SHOWANALYSIS){
            insertMenu(JGR.MAINRCONSOLE,analysisMenu,menuIndex);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "Frequencies", "frequency", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "Descriptives", "descriptives", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "Contingency Tables", "contingency", cListener);
            EzMenuSwing.getMenu(JGR.MAINRCONSOLE, analysisMenu).addSeparator();
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "One Sample Test", "onesample", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "Two Sample Test", "two sample", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "K-Sample Test", "ksample", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "Correlation", "corr", cListener);
            EzMenuSwing.getMenu(JGR.MAINRCONSOLE, analysisMenu).addSeparator();

            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "Linear Model", "linear", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "Logistic Model", "logistic", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, analysisMenu, "Generalized Linear Model", "glm", cListener);
            menuIndex++;
            }



            insertMenu(JGR.MAINRCONSOLE,"Plots",menuIndex);
            //EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, "Plots", "Open plot", "openplot", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, "Plots", "Plot Builder", "plotbuilder", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, "Plots", "Import Template", "Import template", cListener);
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, "Plots", "Open Plot", "Open plot", cListener);
            JMenu sm = new JMenu("Templates");
            sm.setMnemonic(KeyEvent.VK_S);
            String[] labels = new String[] {"Histogram","Pie","Box-plot","Bar","Scatter","Line","Series","Bubble"};
            String[] cmds = new String[] {"histogram","pie","boxplot","bar","scatter","line","series","bubble"};
            for(int i = 0;i<labels.length;i++){
            JMenuItem mi = new JMenuItem();
            mi.setText(labels[i]);
            mi.setActionCommand(cmds[i]);
            mi.addActionListener(cListener);
            sm.add(mi);
            }
            JMenu menu = EzMenuSwing.getMenu(JGR.MAINRCONSOLE, "Plots");
            menu.add(sm);
            menu.addSeparator();

            sm = new JMenu("Interactive");
            sm.setMnemonic(KeyEvent.VK_S);
            labels = new String[] {"Scatter","Histogram","Bar","Box-plot (long)","Box-plot (wide)","Mosaic","Parallel Coordinate"};
            cmds = new String[] {"iplot","ihist","ibar","iboxl","iboxw","imosaic","ipcp"};
            for(int i = 0;i<labels.length;i++){
            JMenuItem mi = new JMenuItem();
            mi.setText(labels[i]);
            mi.setActionCommand(cmds[i]);
            mi.addActionListener(cListener);
            sm.add(mi);
            }
            menu.add(sm);

            menuIndex++;


            //Replace DataTable with Data Viewer
            JGR.MAINRCONSOLE.getJMenuBar().getMenu(menuIndex).remove(1);
            insertJMenuItem(JGR.MAINRCONSOLE, "Packages & Data", "Data Viewer", "table", cListener, 1);

            //Override New Data with Data Viewer enabled version
            JGR.MAINRCONSOLE.getJMenuBar().getMenu(0).remove(0);
            insertJMenuItem(JGR.MAINRCONSOLE, "File", "New Data", "New Data Set", cListener, 0);

            //Override Open Data with Data Viewer enabled version
            JGR.MAINRCONSOLE.getJMenuBar().getMenu(0).remove(1);
            insertJMenuItem(JGR.MAINRCONSOLE, "File", "Open Data", "Open Data Set", cListener, 1);
            JMenuItem open = (JMenuItem)JGR.MAINRCONSOLE.getJMenuBar().getMenu(0).getMenuComponent(1);
            open.setAccelerator(KeyStroke.getKeyStroke('L',MENUMODIFIER));

            //Save Data
            insertJMenuItem(JGR.MAINRCONSOLE, "File", "Save Data", "Save Data Set", cListener, 2);
             */

            //help
            EzMenuSwing.addJMenuItem(JGR.MAINRCONSOLE, "Help", "SimDat Help", "sdhelp", cListener);

            //preferences
            PrefPanel prefs = new PrefPanel();
            PrefDialog.addPanel(prefs, prefs);
            started = true;
        } catch (Exception e) {
            e.printStackTrace();
            new ErrorMsg(e);
        }
    }

    public static boolean isJGR() {

        return insideJGR;
    }

    public void detach() {
        JMenuBar mb = JGR.MAINRCONSOLE.getJMenuBar();
        for (int i = 0; i < mb.getMenuCount(); i++) {
            if (mb.getMenu(i).getText().equals("SimDat")) {
                mb.remove(i);
                i--;
            }
        }
    }

    public static void startViewerAndWait() {
        SimDatMain inst = new SimDatMain();
        inst.setLocationRelativeTo(null);
        inst.setVisible(true);
        while (inst.isVisible() == false) {
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
            }
        }
    }

    public static String addSlashes(String str) {
        if (str == null) {
            return "";
        }

        StringBuffer s = new StringBuffer(str);
        for (int i = 0; i < s.length(); i++) {
            if (s.charAt(i) == '\\') {
                s.insert(i++, '\\');
            } else if (s.charAt(i) == '\"') {
                s.insert(i++, '\\');
            } else if (s.charAt(i) == '\'') {
                s.insert(i++, '\\');
            }
        }

        return s.toString();
    }

    class ConsoleListener implements ActionListener {

        public void actionPerformed(ActionEvent arg0) {
            String cmd = arg0.getActionCommand();
            runCmdThreaded(cmd);
        }
    }

    public static void runCmdThreaded(String cmd) {
        final String c = cmd;
        (new Thread() {

            public void run() {
                runCmd(c, false);
            }
        }).start();
    }

    public static void runCmd(String cmd, boolean fromConsole) {
        boolean needsRLocked = false;
        if (cmd.equals("sdhelp")) {
            HelpButton.showInBrowser(HelpButton.baseUrl + "pmwiki.php?n=Main.DeducerManual");
        } else if (cmd.equals("New Model")) {
            String inputValue = JOptionPane.showInputDialog("Model Name: ");
            if (inputValue != null) {
                String var = RController.makeValidVariableName(inputValue.trim());
                execute(var + "new(\"SimDatModel\",name=\")" + var + "\")"); // TODO
                //DataFrameWindow.setTopDataWindow(var);
            }
        } else if (cmd.equals("Open Model")) {
            //needsRLocked=true;
            LoadModel inst = new LoadModel();
            //DataFrameWindow.setTopDataWindow(inst.getDataName());
            SimDat.setRecentModel(inst.getModelName());
        } else if (cmd.equals("Save Model")) {
            //needsRLocked=true;
            RObject model = (new ModelSelector(JGR.MAINRCONSOLE)).getSelection();
            if (model != null) {
                SaveModel inst = new SaveModel(model.getName());
                //WindowTracker.addWindow(inst);
            }
        } else if (cmd.equals("Open Workspace")) {
            //needsRLocked=true;
            LoadWorkspace inst = new LoadWorkspace();
            //DataFrameWindow.setTopDataWindow(inst.getDataName());
            //SimDat.setRecentWork(inst.getWorkspaceName());
        } else if (cmd.equals("Save Workspace")) {
            //needsRLocked=true;
            //RObject data = (new WorkspaceSelector(JGR.MAINRCONSOLE)).getSelection();
            //if(data!=null){
            SaveWorkspace inst = new SaveWorkspace();
            //WindowTracker.addWindow(inst);
            //}
        }

        if (needsRLocked && fromConsole && !isJGR()) {
            WindowTracker.waitForAllClosed();
        }

    }
    //temporary until new version of ibase

    public static void insertMenu(JFrame f, String name, int index) {
        JMenuBar mb = f.getJMenuBar();
        JMenu m = EzMenuSwing.getMenu(f, name);
        if (m == null && index < mb.getMenuCount()) {
            JMenuBar mb2 = new JMenuBar();
            int cnt = mb.getMenuCount();
            for (int i = 0; i < cnt; i++) {
                if (i == index) {
                    mb2.add(new JMenu(name));
                }
                mb2.add(mb.getMenu(0));
            }
            f.setJMenuBar(mb2);
        } else if (m == null && index == mb.getMenuCount()) {
            EzMenuSwing.addMenu(f, name);
        }
    }

    public static void insertJMenuItem(JFrame f, String menu, String name,
            String command, ActionListener al, int index) {
        JMenu m = EzMenuSwing.getMenu(f, menu);
        JMenuItem mi = new JMenuItem(name);
        mi.addActionListener(al);
        mi.setActionCommand(command);
        m.insert(mi, index);
    }

    public static String getRecentModel() {
        return recentActiveModel;
    }

    public static void setRecentModel(String model) {
        recentActiveModel = model;
    }

    public static REngine getREngine() {
        return rConnection.getREngine();
    }

    public static RConnector getRConnector() {
        return rConnection;
    }

    public static void setRConnector(RConnector rc) {
        rConnection = rc;
    }

    /*
    public static REXPEnvironment getGuiREnv {
    REXPLogical exists = (REXPLogical) rConnection.eval("exists(\"" + SimDat.guiEnv + "\")");
    if(exists.isFALSE()[0]) {
    // create
    rConnection.eval(SimDat.guiEnv + "<- new.env()");
    }
    REXPLogical isenv = (REXPLogical) rConnection.eval("is.environment(\"" + SimDat.guiEnv + "\")");
    if(isenv.isFALSE()[0]) {

    }
    try {
    guiREnv = (REXPEnvironment) rConnection.eval(SimDat.guiEnv);
    } catch (Exception e) {
    new ErrorMsg(e);
    return new REXPEnvironment( );
    }

    SimDat.GlobalEval(SimDat.guiEnv + "<- new.env()");
    }
     */
    public static REXP eval(String cmd) {
        cmd = "evalq(" + cmd + ",envir = " + SimDat.guiEnv + ")";
        return rConnection.eval(cmd);
    }

    public static REXP eval(String cmd, String env) {
        //cmd = "eval(parse(text =" + cmd + "),envir = " + guiEnv + ")";
        cmd = "evalq(" + cmd + ",envir = " + env + ")";
        return rConnection.eval(cmd);
    }

    public static REXP eval(String[] cmd) {
        // TODO: change this to execute!
        String tcmd;
        for (int i = 0; i < cmd.length - 1; i++) {
            tcmd = "evalq(" + cmd[i] + ",envir = " + SimDat.guiEnv + ")";
            //return rConnection.eval(cmd);
            rConnection.eval(tcmd);
        }
        tcmd = "evalq(" + cmd[cmd.length - 1] + ",envir = " + SimDat.guiEnv + ")";
        return rConnection.eval(tcmd);

    }

    public static REXP GlobalEval(String cmd) {
        //cmd = "eval(parse(text =" + cmd + "),envir = " + guiEnv + ")";
        return rConnection.eval(cmd);
    }

    public static REXP idleEval(String cmd) {
        return rConnection.idleEval(cmd);
    }


    public static void execute(String cmd) {
        //cmd = "evalq(" + cmd + ",envir = " + SimDat.guiEnv + ")";
        cmd = "evalq(" + cmd + ",envir = " + SimDat.guiEnv + ")";
        //return
        rConnection.eval(cmd);
        //rConnection.execute(cmd);
    }



   public static void execute(String cmd, String env) {
        cmd = "evalq(" + cmd + ",envir = " + env + ")";
        //rConnection.execute(cmd,hist);
        rConnection.eval(cmd);
    }


   public static void execute(String[] cmd) {
        for (int i = 0; i < cmd.length; i++) {
            String tcmd = "evalq(" + cmd[i] + ",envir = " + SimDat.guiEnv + ")";
            //return rConnection.eval(cmd);
            rConnection.eval(tcmd);
            //rConnection.execute(tcmd);
        }
    }

   public static void execute(String[] cmd, String env) {
        for (int i = 0; i < cmd.length; i++) {
            String tcmd = "evalq(" + cmd[i] + ",envir = " + SimDat.guiEnv + ")";
            //return rConnection.eval(cmd);
            rConnection.eval(tcmd);
            //rConnection.execute(tcmd);
        }
    }

    public static void execute(String cmd, boolean hist) {
        cmd = "evalq(" + cmd + ",envir = " + SimDat.guiEnv + ")";
        //rConnection.execute(cmd,hist);
        rConnection.eval(cmd);
    }

    public static void executeAndContinue(String cmd) {
        final String c = cmd;
        (new Thread() {

            public void run() {
                execute(c);
            }
        }).start();
    }

    public static String makeValidVariableName(String var) {
        return var.replaceAll("[ -+*/\\()=!~`@#$%^&*<>,?;:\"\']", ".");
    }

    public static String makeFormula(DefaultListModel outcomes, DefaultListModel terms) {
        String formula = "";
        if (outcomes.getSize() == 1) {
            formula += outcomes.get(0) + " ~ ";
        } else {
            formula += "cbind(";
            for (int i = 0; i < outcomes.getSize(); i++) {
                formula += outcomes.get(i);
                if (i < outcomes.getSize() - 1) {
                    formula += ",";
                }
            }
            formula += ") ~ ";
        }
        for (int i = 0; i < terms.getSize(); i++) {
            formula += terms.get(i);
            if (i < terms.getSize() - 1) {
                formula += " + ";
            }
        }
        return formula;
    }

    public static String makeRCollection(Collection lis, String func, boolean quotes) {
        String q = "";
        if (quotes) {
            q = "\"";
        }
        if (lis.size() == 0) {
            return func + "()";
        }
        String result = func + "(";
        Iterator it = lis.iterator();
        int ins = 1;
        while (it.hasNext()) {
            String s = it.next().toString();
            result += q + s + q;
            if (it.hasNext()) {
                result += ",";
            }
            if (ins % 10 == 9) {
                result += "\n";
            }
            ins++;
        }
        return result + ")";
    }

    public static String makeRCollection(ListModel lis, String func, boolean quotes) {
        ArrayList a = new ArrayList();
        for (int i = 0; i < lis.getSize(); i++) {
            a.add(lis.getElementAt(i));
        }
        return makeRCollection(a, func, quotes);
    }

    public static String makeRCollection(String[] lis, String func, boolean quotes) {
        ArrayList a = new ArrayList();
        for (int i = 0; i < lis.length; i++) {
            a.add(lis[i]);
        }
        return makeRCollection(a, func, quotes);
    }

    /**
     * Gets a unique name based on a starting string
     *
     * @param var
     * @return the value of var concatinated with a number
     */
    public static String getUniqueName(String var) {
        JGR.refreshObjects();
        var = RController.makeValidVariableName(var);
        if (!JGR.OBJECTS.contains(var)) {
            return var;
        }
        int i = 1;
        while (true) {
            if (!JGR.OBJECTS.contains(var + i)) {
                return var + i;
            }
            i++;
        }
    }

    /**
     * Gets a unique name based on a starting string
     *
     * @param var
     * @param envName
     *            The name of the enviroment in which to look
     * @return the value of var concatinated with a number
     */
    public static String getUniqueName(String var, String envName) {
        var = RController.makeValidVariableName(var);

        try {
            REXPLogical temp = (REXPLogical) eval("is.environment("
                    + envName + ")");
            boolean isEnv = temp.isTRUE()[0];
            if (!isEnv) {
                return var;
            }
        } catch (Exception e) {
            new ErrorMsg(e);
            return var;
        }

        boolean isUnique = false;

        try {

            REXPLogical temp = (REXPLogical) eval("exists('" + var
                    + "',where=" + envName + ",inherits=FALSE)");
            isUnique = temp.isFALSE()[0];
            if (isUnique) {
                return var;
            }

        } catch (Exception e) {
            new ErrorMsg(e);
            return var;
        }

        int i = 1;
        while (true) {

            try {

                REXPLogical temp = (REXPLogical) eval("exists('" + (var + i) + "',where=" + envName
                        + ",inherits=FALSE)");
                isUnique = temp.isFALSE()[0];

            } catch (Exception e) {
                new ErrorMsg(e);
            }

            if (isUnique) {
                return var + i;
            }
            i++;
        }
    }

    /**
     * is package installed
     * @param packageName
     * @return
     */

    public static boolean envDefined(String env) {
        boolean defined = false;
        String checkEnv = "";
        String whereEnv = "";
        String[] subenv = env.split("\\$");
        if(subenv.length > 1) {
            checkEnv = subenv[subenv.length - 1];
            for(int i = 0; i < (subenv.length - 1); i++) {
                whereEnv += subenv[i];
                if(i < subenv.length - 2)
                    whereEnv += "$";
            }
            defined = ((REXPLogical) SimDat.eval("exists('" + checkEnv + "',inherits=FALSE) && is.environment(" + checkEnv + ")",whereEnv)).isTRUE()[0];
        } else {
            defined = ((REXPLogical) SimDat.GlobalEval("exists('" + env + "',inherits=FALSE) && is.environment(" + env + ")")).isTRUE()[0];
        }
        //defined = ((REXPLogical) SimDat.GlobalEval("exists('" + curEnv + "') && is.environment('" + curEnv + "')")).isTRUE()[0];
        return defined;
    }

    public static boolean isInstalled(String packageName) {
        REXP installed = SimDat.eval("'" + packageName + "' %in% installed.packages()[,1]");
        if (installed != null && installed instanceof REXPLogical) {
            return ((REXPLogical) installed).isTRUE()[0];
        }
        return false;
    }

    /**
     * is package loaded
     * @param packageName
     * @return
     */
    public static boolean isLoaded(String packageName) {
        REXP loaded = SimDat.eval("'" + packageName + "' %in% c(names(sessionInfo()$otherPkgs), sessionInfo()$base)");
        if (loaded != null && loaded instanceof REXPLogical) {
            return ((REXPLogical) loaded).isTRUE()[0];
        }
        return false;
    }

    /**
     * Checks if package is installed, and asks to install if not.
     * @param packageName
     * @return "loaded", "installed" or "not-installed"
     */
    public static String requirePackage(String packageName) {
        if (isLoaded(packageName)) {
            return "loaded";
        }
        if (isInstalled(packageName)) {
            return "installed";
        }
        int inst = JOptionPane.showOptionDialog(null, "Package " + packageName + " not installed. \nWould you like to install it now?",
                "Install", JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE, null,
                new String[]{"Yes", "No"}, "Yes");
        if (inst == JOptionPane.OK_OPTION) {
            SimDat.eval("install.packages('" + packageName + "',,'http://cran.r-project.org')");
            if (isInstalled(packageName)) {
                return "installed";
            }
        }
        return "not-installed";
    }

    public static synchronized void refreshModels() {
        //REXP x = SimDat.idleEval(".getSimDatModels()");
        REXP x = SimDat.eval(".getSimDatModels()"); // TODO: set back to idleEval
        if (x == null) {
            return;
        }
        String[] data;
        MODELS.clear();
        try {
            if (!x.isNull() && (data = x.asStrings()) != null) {
                int a = 1;
                for (int i = 0; i < data.length; i++) {
                    boolean b = (data[i].equals("null") || data[i].trim().length() == 0);
                    String name = b ? a + "" : data[i];
                    String t = "";
                    if (b == false)
                           t = (SimDat.eval("is(" + data[i] + ")")).asStrings()[0]; // TODO: set back to idleEval
                    
                    MODELS.add(RController.createRObject(name, t, null, (!b)));
                    a++;
                }

            }
        } catch (REXPMismatchException e) {
        }
    }

    public static Vector getModels() {
        return MODELS;
    }

    /**
     * Refreshes objects and keywords if JGR is not doing so.
     */
    class DataRefresher implements Runnable {

        public DataRefresher() {
        }

        public void run() {
            while (true) {
                try {
                    Thread.sleep(1000);
                    refreshModels();
                } catch (Exception e) {
                    new ErrorMsg(e);
                }
            }
        }
    }
}
