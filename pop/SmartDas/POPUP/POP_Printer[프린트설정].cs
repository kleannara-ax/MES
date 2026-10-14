using System;
using System.Windows.Forms;
using System.Configuration;
using System.Data;

namespace SmartDas.POPUP
{
    public partial class POP_Printer : Form
    {
        private DataTable pdt;

        public POP_Printer()
        {
            InitializeComponent();
        }

        private void POP_Printer_Load(object sender, EventArgs e)
        {
            pdt = PrinterManager.GetPrinterList();
            if (pdt.Rows.Count > 0)
            {
                ucPrinter.DataSource = pdt;
                ucPrinter.ValueMember = "PRINTER";
                ucPrinter.DisplayMember = "PRINTER";
            }

            upGapY.Text = SAMMI.IniFile.GetValue("KLEANNARA", "PRT_GAP_Y", "0");
            ucPrinter.Text = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", "");
            ucPrtDPI.Text = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTERDPI", "");
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void btnInput_Click(object sender, EventArgs e)
        {
            SAMMI.IniFile.SetValue("KLEANNARA", "PRINTER", ucPrinter.Text);
            SAMMI.IniFile.SetValue("KLEANNARA", "PRINTERDPI", ucPrtDPI.Text);
            SAMMI.IniFile.SetValue("KLEANNARA", "PRT_GAP_Y", upGapY.Text);

            this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }
        
        private void doTestPrint()
        {
            string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", "");

            string sZPL = "^XA ";
            //sZPL = sZPL + "^LH0,250 ";         //LabelHome : 기준점을 SET시킨다.
            //sZPL = sZPL + "^MD,~SD20 ";         // 농도 1-30
            //sZPL = sZPL + "^PR4 ";              // 속도 12
            sZPL = sZPL + "^SEE:UHANGUL.DAT^FS ";
            sZPL = sZPL + "^CW1,E:KFONT3.FNT^CI26^FS ";


            sZPL = sZPL + "^FO100,235 ^A1N,185,175 ^FD시험 테스트^FS ";
            sZPL = sZPL + "^FO100,480 ^A0N,195,170 ^FD123^FS ";
            sZPL = sZPL + "^FO500,480 ^A0N,195,170 ^FD1234x1234^FS ";

            sZPL = sZPL + "^FO100,690 ^A0N,135,115 ^FD5.0^FS ";
            sZPL = sZPL + "^FO420,700 ^A0N,105,95 ^FD123,456^FS ";
            sZPL = sZPL + "^FO100,850 ^A0N,135,115 ^FD100^FS ";
            sZPL = sZPL + "^FO535,850 ^A0N,135,115 ^FD30^FS ";
            sZPL = sZPL + "^FO100,1015 ^A0N,95,105 ^FD100^FS ";
            sZPL = sZPL + "^FO535,1015 ^A0N,95,105 ^FD12^FS ";

            sZPL = sZPL + "^FO65,1185 ^A0N,95,95 ^FD111222333^FS ";
            sZPL = sZPL + "^FO535,1235 ^A0N,60,60 ^FD1,000^FS ";
            sZPL = sZPL + "^FO535,1335 ^A1N,75,60 ^FD2,000^FS ";
            sZPL = sZPL + "^FO535,1385 ^A0N,50,50 ^FD3,000^FS ";
            sZPL = sZPL + "^FO535,2060 ^A1N,50,50 ^FD4,000^FS ";
            sZPL = sZPL + "^FO535,1455 ^A0N,95,95 ^FD5,000^FS ";
            sZPL = sZPL + "^FO535,1530 ^A1N,50,50 ^FD5,000^FS ";
            sZPL = sZPL + "^FO535,1605 ^A0N,95,95 ^FD6,000^FS ";

            sZPL = sZPL + "^FO865,630 ";
            sZPL = sZPL + "^BY6,2,10 ";
            sZPL = sZPL + "^BCR,295,N,N,N ";
            sZPL = sZPL + "^FD 21C30M0411 ";
            sZPL = sZPL + "^FS ";
            sZPL = sZPL + "^FO1185,650 ^A0B,120,180 ^FD21C30M0411^FS ";

            sZPL = sZPL + "^XZ";

            foreach (string sPrinter in System.Drawing.Printing.PrinterSettings.InstalledPrinters)
            {
                if (sPrinter.Contains(PrinterName))
                {
                    string rtnMsg = PrinterManager.CheckPrinterState(sPrinter);
                    if (rtnMsg == "OK")
                    {
                        SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);
                    }
                    else
                    {
                        new POPUP.MessageForm(rtnMsg, MessageBoxButtons.OK, "알   림").ShowDialog();
                    }

                    break;
                }
            }
        }

        private void btnTestPrint_Click(object sender, EventArgs e)
        {
            doTestPrint();
        }
    }
}
