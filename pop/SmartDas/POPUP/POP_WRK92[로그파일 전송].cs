using System;
using System.Drawing;
using System.Windows.Forms;
using System.Net;
using System.Net.Sockets;
using System.IO;

namespace SmartDas.POPUP
{
    public partial class POP_WRK92 : Form
    {
        //private string sPlantCode = string.Empty;
        //private string sMachCode = string.Empty;
        ////접속 관리
        //public RfcConfigParameters rfc = null;
        //public RfcDestination rfcDest = null;
        //public RfcRepository rfcRep = null;
        ////SAP 호출
        //public IRfcFunction function = null;
        //private string sIFID = string.Empty;
        //private string sIFKey = string.Empty;
        ////결과정보
        //public IRfcStructure rtnStruct = null;
        //public DataTable rtnTable = null;
        //public string rtnCD = string.Empty;
        //public string rtnMSG = string.Empty;

        // 플랜트코드, 작업지시번호, 작업지시순번, 업체/개별바코드, OperationType
        public POP_WRK92()
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void POP_WRK92_Load(object sender, EventArgs e)
        {
        }

        #region < METHOD AREA >

        #endregion

        #region < EVENT AREA >

        private void ftpSendFile()
        {
            // FTP 전송
            string addr = string.Empty;
            string user = string.Empty;
            string pwd = string.Empty;
            string port = string.Empty;

            addr = "10.2.14.190";
            port = "21";
            user = "KNRADEV";
            pwd = "kleannara12#";

            FTPManager manager = new FTPManager();

            bool result = manager.ConnectToServer(addr, port, user, pwd);

            // 로컬 IP 받아오기
            IPHostEntry hostAddress = Dns.GetHostEntry(Dns.GetHostName());
            string localIp = string.Empty;
            string sourceFilePath, targetFilePath, sourceFileName, targetFolder, targetFileName;
            sourceFileName = dtpSendDate.Value.ToString("yyyy-MM-dd") + ".txt";

            foreach (IPAddress ip in hostAddress.AddressList)
            {
                if (ip.AddressFamily == AddressFamily.InterNetwork)
                {
                    localIp = ip.ToString();
                    targetFolder = localIp;
                }
            }

            string path = string.Empty;
            string fileName = string.Empty;
            string localPath = @"C:\Kleannara\Log";
            int fileCnt = 0;
            path = @"POP_LOG\" + localIp;
            DirectoryInfo dirInfo = new DirectoryInfo(localPath);
            FileInfo[] infos = dirInfo.GetFiles();

            if (result == true)
            {
                Console.WriteLine("Connect Success");

                if (chkMonth.Text == "V")
                {
                    foreach (FileInfo info in dirInfo.GetFiles(sourceFileName.Substring(0, 7) + "*.txt"))
                    {
                        if (Path.GetExtension(info.Name) == ".txt")
                        {
                            if (manager.UpLoad(path, info.FullName) == false)
                            {
                                Console.WriteLine("FTP UPLOAD Fail!!");
                            }
                            else
                            {
                                Console.WriteLine("FTP UPLOAD Success!!");
                                fileCnt++;
                            }
                        }
                    }
                    lblTitle.Text = dtpSendDate.Value.ToString("yyyy-MM") + " 월 " + fileCnt.ToString() + " 건 Log 전송 성공!!";
                }
                else
                {
                    foreach (FileInfo info in dirInfo.GetFiles(sourceFileName))
                    {
                        if (Path.GetExtension(info.Name) == ".txt")
                        {
                            if (manager.UpLoad(path, info.FullName) == false)
                            {
                                Console.WriteLine("FTP UPLOAD Fail!!");
                            }
                            else
                            {
                                Console.WriteLine("FTP UPLOAD Success!!");
                            }
                        }
                    }
                    lblTitle.Text = dtpSendDate.Value.ToString("yyyy-MM-dd") + " 일자 Log 전송 성공!!";
                }
            }
            else
            {
                Console.WriteLine("FTP Connect Fail!!");
            }
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                ftpSendFile();
                return;
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("로그파일 전송 Error => " + ex.Message);
            }
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }
        #endregion

        private void chkMonth_Click(object sender, EventArgs e)
        {
            if (chkMonth.Text.ToString().Equals("V"))
            {
                chkMonth.Text = "";
                chkMonth.BackColor = Color.White;
            }
            else
            {
                chkMonth.Text = "V";
                chkMonth.BackColor = Color.Yellow;
            }
        }

        private void butStartDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(dtpSendDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpSendDate.Value = DateTime.Parse(strDate);
            }
        }
    }
    class FTPManager
    {
        public delegate void ExceptionEventHandler(string LocationID, Exception ex);
        public event ExceptionEventHandler ExceptionEvent;

        public Exception LastException = null;

        public bool IsConnected { get; set; }

        private string ipAddr = string.Empty;
        private string port = string.Empty;
        private string userId = string.Empty;
        private string pwd = string.Empty;

        public FTPManager()
        {

        }

        public bool ConnectToServer(string ip, string port, string userId, string pwd)
        {
            this.IsConnected = false;

            this.ipAddr = ip;
            this.port = port;
            this.userId = userId;
            this.pwd = pwd;

            string url = string.Format(@"FTP://{0}:{1}/", this.ipAddr, this.port);

            try
            {
                FtpWebRequest ftpRequest = (FtpWebRequest)WebRequest.Create(url);
                ftpRequest.Credentials = new NetworkCredential(userId, pwd);
                ftpRequest.KeepAlive = false;
                ftpRequest.Method = WebRequestMethods.Ftp.ListDirectory;
                ftpRequest.UsePassive = false;

                using (ftpRequest.GetResponse())
                {

                }

                this.IsConnected = true;
            }
            catch (Exception ex)
            {
                this.LastException = ex;

                System.Reflection.MemberInfo info = System.Reflection.MethodInfo.GetCurrentMethod();
                string id = string.Format("{0}.{1}", info.ReflectedType.Name, info.Name);

                if (this.ExceptionEvent != null)
                {
                    this.ExceptionEvent(id, ex);
                }

                return false;
            }
            return true;
        }

        public bool UpLoad(string folder, string filename)
        {
            return upload(folder, filename);
        }

        private bool upload(string folder, string filename)
        {
            try
            {
                makeDir(folder);

                FileInfo fileInf = new FileInfo(filename);

                folder = folder.Replace('\\', '/');
                filename = filename.Replace('\\', '/');

                string url = string.Format(@"FTP://{0}:{1}/{2}/{3}", this.ipAddr, this.port, folder, fileInf.Name);
                FtpWebRequest ftpRequest = (FtpWebRequest)WebRequest.Create(url);
                ftpRequest.Credentials = new NetworkCredential(userId, pwd);
                ftpRequest.KeepAlive = false;
                ftpRequest.UseBinary = false;
                ftpRequest.UsePassive = false;

                ftpRequest.Method = WebRequestMethods.Ftp.UploadFile;
                ftpRequest.ContentLength = fileInf.Length;

                int buffLength = 2048;
                byte[] buff = new byte[buffLength];
                int contentLen;

                using (FileStream fs = fileInf.OpenRead())
                {
                    using (Stream strm = ftpRequest.GetRequestStream())
                    {
                        contentLen = fs.Read(buff, 0, buffLength);

                        while (contentLen != 0)
                        {
                            strm.Write(buff, 0, contentLen);
                            contentLen = fs.Read(buff, 0, buffLength);
                        }
                    }

                    fs.Flush();
                    fs.Close();
                }

                if (buff != null)
                {
                    Array.Clear(buff, 0, buff.Length);
                    buff = null;
                }
            }
            catch (Exception ex)
            {
                this.LastException = ex;

                System.Reflection.MemberInfo info = System.Reflection.MethodInfo.GetCurrentMethod();
                string id = string.Format("{0}.{1}", info.ReflectedType.Name, info.Name);

                if (this.ExceptionEvent != null)
                {
                    this.ExceptionEvent(id, ex);
                }

                return false;
            }

            return true;
        }

        private void makeDir(string dirName)
        {
            string[] arrDir = dirName.Split('\\');
            string currentDir = string.Empty;

            try
            {
                foreach (string tmpFolder in arrDir)
                {
                    try
                    {
                        if (tmpFolder == string.Empty) continue;

                        currentDir += @"/" + tmpFolder;

                        string url = string.Format(@"FTP://{0}:{1}{2}", this.ipAddr, this.port, currentDir);
                        FtpWebRequest ftpRequest = (FtpWebRequest)WebRequest.Create(url);
                        ftpRequest.Credentials = new NetworkCredential(userId, pwd);

                        ftpRequest.Method = WebRequestMethods.Ftp.MakeDirectory;
                        ftpRequest.KeepAlive = false;
                        ftpRequest.UsePassive = false;

                        FtpWebResponse response = (FtpWebResponse)ftpRequest.GetResponse();
                        response.Close();
                    }
                    catch { }
                }
            }
            catch (Exception ex)
            {
                this.LastException = ex;

                System.Reflection.MemberInfo info = System.Reflection.MethodInfo.GetCurrentMethod();
                string id = string.Format("{0}.{1}", info.ReflectedType.Name, info.Name);

                if (this.ExceptionEvent != null)
                {
                    this.ExceptionEvent(id, ex);
                }

            }
        }

        private void checkDir(string localFullPathFile)
        {
            FileInfo fInfo = new FileInfo(localFullPathFile);

            if (!fInfo.Exists)
            {
                DirectoryInfo dInfo = new DirectoryInfo(fInfo.DirectoryName);
                if (!dInfo.Exists)
                {
                    dInfo.Create();
                }
            }
        }

    }
}
