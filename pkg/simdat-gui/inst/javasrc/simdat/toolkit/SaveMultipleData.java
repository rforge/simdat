package simdat.toolkit;

import simdat.SimDat;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.filechooser.FileFilter;
import javax.swing.JPanel;
import javax.swing.BoxLayout;
import javax.swing.JSpinner;
import javax.swing.SpinnerNumberModel;
import javax.swing.JLabel;

import org.rosuda.JGR.toolkit.ExtensionFileFilter;
import org.rosuda.JGR.toolkit.FileSelector;
//import org.rosuda.deducer.Deducer;

public class SaveMultipleData {

    /**
     *
     */
    private static final long serialVersionUID = -5513844930423188258L;
    private static String extensions[][] = new String[][]{{"rda", "rdata"}, {"robj"}, {"csv"}, {"txt"}, {"dbf"}, {"dta"}, {"arff"}};
    private static String extensionDescription[] = new String[]{"R (*.rda *.rdata)", "R dput() (*.robj)", "Comma seperated (*.csv)", "Tab (*.txt)",
        "DBF (*.dbf)", "Stata (*.dta)", "ARFF (*.arff)"};
    private JPanel fpanel;

    public SaveMultipleData(String modelName) {
        String fileBase; // base name
        String fileExt; // extension
        int nrep;
        fpanel = new JPanel();
        fpanel.setLayout(new BoxLayout(fpanel, BoxLayout.X_AXIS));
        SpinnerNumberModel numListModel = new SpinnerNumberModel(1, //initial value
                1, //min
                100000, //max
                1);                //step
        JSpinner numList = new JSpinner(numListModel);
        JLabel numLabel = new JLabel("Number of files:");
        fpanel.add(numLabel);
        fpanel.add(numList);

        JFileChooser chooser = null;
        FileFilter extFilter = null;
        FileSelector fileDialog = new FileSelector(null, "Save Data", FileSelector.SAVE);
        fileDialog.addFooterPanel(fpanel);
        if (fileDialog.isSwing()) {
            chooser = fileDialog.getJFileChooser();
            for (int i = 0; i < extensionDescription.length; i++) {
                extFilter = new ExtensionFileFilter(extensionDescription[i], extensions[i]);
                chooser.addChoosableFileFilter(extFilter);
            }
            chooser.setFileFilter(chooser.getAcceptAllFileFilter());
        }
        fileDialog.setVisible(true);
        if (fileDialog.getFile() == null) {
            return;
        }
        String fileName = fileDialog.getDirectory() + fileDialog.getFile();
        fileName = fileName.replace('\\', '/');
        if (fileDialog.getFile() == null) {
            return;
        }
        if (!fileDialog.isSwing()) {
            if (!fileName.toLowerCase().endsWith(".robj")) {
                fileName = fileName.concat(".robj");
            }
            SimDat.execute("dput(getData(" + modelName + "),'" + fileName + "')", true);
        } else {
            SpinnerNumberModel model = (SpinnerNumberModel) numList.getModel();
            nrep = model.getNumber().intValue();
            if (fileName.toLowerCase().endsWith(".rda") || fileName.toLowerCase().endsWith(".rdata")
                    || chooser.getFileFilter().getDescription().equals(extensionDescription[0])) {
                if (!fileName.toLowerCase().endsWith(".rda") && !fileName.toLowerCase().endsWith(".rdata")) {
                    fileBase = fileName;
                    fileExt = ".rdata";
                    fileName = fileName.concat(".rda");
                } else {
                    fileBase = fileName.substring(0, fileName.lastIndexOf('.'));
                    fileExt = fileName.substring(fileName.lastIndexOf('.'), fileName.length());
                }
                SimDat.execute("for(i in 1:" + nrep + ") save(getData(simulate(" + modelName + ")),file=paste('" + fileBase + "',i,'" + fileExt + "',sep=\"\"))", true);
            } else if (fileName.toLowerCase().endsWith(".robj")
                    || chooser.getFileFilter().getDescription().equals(extensionDescription[1])) {
                if (!fileName.toLowerCase().endsWith(".robj")) {
                    fileBase = fileName;
                    fileExt = ".robj";
                    fileName = fileName.concat(".robj");
                } else {
                    fileBase = fileName.substring(0, fileName.lastIndexOf('.'));
                    fileExt = fileName.substring(fileName.lastIndexOf('.'), fileName.length());
                }
                SimDat.execute("for(i in 1:" + nrep + ") dput(getData(simulate(" + modelName + ")),file=paste('" + fileBase + "',i,'" + fileExt + "',sep=\"\"))", true);
                //SimDat.execute("dput(getData(" + modelName + "),'" + fileName + "')", true);
            } else if (fileName.toLowerCase().endsWith(".csv")
                    || chooser.getFileFilter().getDescription().equals(extensionDescription[2])) {
                if (!fileName.toLowerCase().endsWith(".csv")) {
                    fileBase = fileName;
                    fileExt = ".csv";
                    fileName = fileName.concat(".csv");
                } else {
                    fileBase = fileName.substring(0, fileName.lastIndexOf('.'));
                    fileExt = fileName.substring(fileName.lastIndexOf('.'), fileName.length());
                }
                SimDat.execute("for(i in 1:" + nrep + ") write.csv(getData(simulate(" + modelName + ")),file=paste('" + fileBase + "',i,'" + fileExt + "',sep=\"\"),row.names=FALSE)", true);
                //SimDat.execute("write.csv(getData(" + modelName + "),'" + fileName + "')", true);
            } else if (fileName.toLowerCase().endsWith(".txt")
                    || chooser.getFileFilter().getDescription().equals(extensionDescription[3])) {
                if (!fileName.toLowerCase().endsWith(".txt")) {
                    fileBase = fileName;
                    fileExt = ".txt";
                    fileName = fileName.concat(".txt");
                    //fileName = fileName.concat(".txt");
                } else {
                    fileBase = fileName.substring(0, fileName.lastIndexOf('.'));
                    fileExt = fileName.substring(fileName.lastIndexOf('.'), fileName.length());
                }
                SimDat.execute("for(i in 1:" + nrep + ") write.table(getData(simulate(" + modelName + ")),file=paste('" + fileBase + "',i,'" + fileExt + "',sep=\"\"),sep='\\t')", true);
                //SimDat.execute("write.table(getData(" + modelName + "),'" + fileName + "',sep='\\t')", true);
            } else {
                SimDat.requirePackage("foreign");
                if (fileName.toLowerCase().endsWith(".dbf")
                        || chooser.getFileFilter().getDescription().equals(extensionDescription[4])) {
                    if (!fileName.toLowerCase().endsWith(".dbf")) {
                        fileBase = fileName;
                        fileExt = ".dbf";
                        fileName = fileName.concat(".dbf");
                    } else {
                        fileBase = fileName.substring(0, fileName.lastIndexOf('.'));
                        fileExt = fileName.substring(fileName.lastIndexOf('.'), fileName.length());
                    }
                    SimDat.execute("for(i in 1:" + nrep + ") write.dbf(getData(simulate(" + modelName + ")),file=paste('" + fileBase + "',i,'" + fileExt + "',sep=\"\"))", true);
                    //SimDat.execute("write.dbf(getData(" + modelName + "),'" + fileName + "')", true);
                } else if (fileName.toLowerCase().endsWith(".dta")
                        || chooser.getFileFilter().getDescription().equals(extensionDescription[5])) {
                    if (!fileName.toLowerCase().endsWith(".dta")) {
                        fileBase = fileName;
                        fileExt = ".dta";
                        fileName = fileName.concat(".dta");
                    } else {
                        fileBase = fileName.substring(0, fileName.lastIndexOf('.'));
                        fileExt = fileName.substring(fileName.lastIndexOf('.'), fileName.length());
                    }
                    SimDat.execute("for(i in 1:" + nrep + ") write.dta(getData(simulate(" + modelName + ")),file=paste('" + fileBase + "',i,'" + fileExt + "',sep=\"\"))", true);
                    //SimDat.execute("write.dta(getData(" + modelName + "),'" + fileName + "')", true);
                } else if (fileName.toLowerCase().endsWith(".arff")
                        || chooser.getFileFilter().getDescription().equals(extensionDescription[6])) {
                    if (!fileName.toLowerCase().endsWith(".arff")) {
                        fileBase = fileName;
                        fileExt = ".arff";
                        fileName = fileName.concat(".arff");
                    } else {
                        fileBase = fileName.substring(0, fileName.lastIndexOf('.'));
                        fileExt = fileName.substring(fileName.lastIndexOf('.'), fileName.length());
                    }
                    SimDat.execute("for(i in 1:" + nrep + ") write.arff(getData(simulate(" + modelName + ")),file=paste('" + fileBase + "',i,'" + fileExt + "',sep=\"\"))", true);
                    //SimDat.execute("write.arff(getData(" + modelName + "),'" + fileName + "')", true);
                } else {
                    if (!fileName.toLowerCase().endsWith(".robj")) {
                        fileBase = fileName;
                        fileExt = ".robj";
                        fileName = fileName.concat(".robj");
                    } else {
                        fileBase = fileName.substring(0, fileName.lastIndexOf('.'));
                        fileExt = fileName.substring(fileName.lastIndexOf('.'), fileName.length());
                    }
                    SimDat.execute("for(i in 1:" + nrep + ") dput(getData(simulate(" + modelName + ")),file=paste('" + fileBase + "',i,'" + fileExt + "',sep=\"\"))", true);
                    //SimDat.execute("dput(getData(" + modelName + "),'" + fileName + "')", true);
                }
            }
        }
    }
}
