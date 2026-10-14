using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using Microsoft.Practices.EnterpriseLibrary.Data;
using Microsoft.Practices.EnterpriseLibrary.Common;
using System.Data.Common;

using System.Threading;
using System.Data.SqlClient;
using Infragistics.Win.UltraWinEditors;
using System.Diagnostics;
using SmartDas.POPUP;
using System.Net.NetworkInformation;
using Infragistics.Win.UltraWinTabs;
using SAMMI;


namespace SmartDas.Components
{
    public partial class BaseForm : Form
    {
        private Thread th;
        private bool bSyncTime;
        private DateTime _dTime;
        private bool bLoad = false;
        private bool bSetRecDate = false;

        protected AutoResetEvent AutoReset = new AutoResetEvent(false);
        protected POPUP.BaseProgressForm ProgressForm;
        delegate void ClosePrgFormCallBack();
        protected bool IsShowDialog = false;

        private List<UltraPictureBox> listImg = new List<UltraPictureBox>();

        // 시간 분이 변경되면 이벤트로 알림
        public delegate void UpdateMinuteHandler();
        public event UpdateMinuteHandler UpdateMinuteEvent;


        public bool bUseNetwork;

        private int iMax = 0;
        private int iCount = 0;

        private const string CR = "\x0D";
        private const string LF = "\x0A";
        private MSComm[] _Comm = null;
        private int _iStartPortNo;
        private int _iMaxCnt;
        /// <summary>
        /// data from serialPort is added to the queue as individual chars, 
        /// a struct may be better
        /// </summary>
        public ConcurrentQueue<string> serialDataQueue;
        public FormInfor FormInformation;


        public BaseForm()
        {
            InitializeComponent();

            bUseNetwork = false;

            this.KeyPreview = false;

            listImg.Clear();
            //listImg.Add(imgSammi);
            
            foreach (UltraPictureBox pBox in listImg)
            {
                if (pBox.Tag.ToString() == Common.PlantCode)
                {
                    pBox.Visible = true;
                }
                else
                {
                    pBox.Visible = false;
                }
            }
            //this.lblMessage.StartMarquee();
            //Common.SetLineMessage();

            lblMachineName.Text = "";

            if (Common.ProgVersion == null)
            {
//                Version version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version;
//                Common.ProgVersion = String.Format("Ver: {0}.{1}.{2}.{3}", version.Major, version.Minor, version.Build, version.Revision);
                Common.ProgVersion = getVersionDateTime();
            }

            if (Common.IpAddrInfo == null) 
            { 
                Common.IpAddrInfo = String.Format("IP: {0}", Common.GetIPAddress()); 
            }

            if (Common.WorkCrewName == null) { Common.WorkCrewName = "작업조"; }

            if (Common.UserName == null) { Common.UserName = "작업자"; }

            if (Common.MachineName == null) { Common.MachineName = "작업호기"; }

            lblDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            lblTime.Text = DateTime.Now.ToString("HH:mm:ss");

            serialDataQueue = new ConcurrentQueue<string>();

            this.WindowState = FormWindowState.Normal;
            this.StartPosition = FormStartPosition.Manual;
            this.Location = new Point(0, 0);

//#if DEBUG
//            lblTitle.MoveControl = this;
//#endif
            
            if (Common.bFirstTime == false)
            {
                LogFile.WriteLog(string.Format(" POP 프로그램 시작 [{0}, {1}]", Common.IpAddrInfo, Common.ProgVersion), LogType.PROC);

                // 처음 실행시 한번만 사용
                Common.bFirstTime = true;
                Application.ApplicationExit += new EventHandler(this.OnApplicationExit);

                REPORT RP = new REPORT();
                RP.EXCEL_COPY(Common.PlantCode);
            }
        }

        ~BaseForm()
        {
            //this.lblMessage.StopMarquee();

            if (th != null)
            {
                th.Abort();
                th = null;
            }
        }

        
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (!DesignMode)
            {
                //if (this.MdiParent != null)
                //{
                FormInformation = new FormInfor("DAS", this.Name, SAMMI.Common.Lang);
                FormInformation.ManageForm(this);
                //}

                ReDrawInfomation();
            }

        }


        /// <summary>
        /// 버전, 아이피주소, 작업조, 작업자, 작업호기 정보를 표시
        /// </summary>
        public void ReDrawInfomation()
        {
            lblVer_Ip.Text = Common.IpAddrInfo + Environment.NewLine + Common.ProgVersion;
            lblWorker.Text = Common.WorkCrewName + Environment.NewLine + Common.UserName;
            lblMachineName.Text = Common.MachineName;
            if (Common.bDBRealServer == false)
            {
                lblVer_Ip.BackColor = Color.Brown;
                lblWorker.BackColor = Color.Brown;
            }
        }

        /// <summary>
        /// 작업조, 작업자 정보를 갱신
        /// </summary>
        public void ShowInfoWorker(string sWorkCrew, string sUserName)
        {
            Common.WorkCrewName = sWorkCrew;
            Common.UserName = sUserName;
            lblWorker.Text = Common.WorkCrewName + Environment.NewLine + Common.UserName;
        }

        /// <summary>
        /// 작업호기 정보를 갱신
        /// </summary>
        public void ShowInfoMachineName(string sMachineName)
        {
            Common.MachineName = sMachineName;
            lblMachineName.Text = Common.MachineName;
        }

        /// <summary>
        /// Version Text로부터 Build된 일시를 구합니다.
        /// </summary>
        /// <returns></returns>
        public string getVersionDateTime()
        {
            Version version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version;

            //1. Assembly.GetExecutingAssembly().FullName의 값은 
            //'ApplicationName, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null'
            //와 같다. 

            string strVersionText = System.Reflection.Assembly.GetExecutingAssembly().FullName
                    .Split(',')[1]
                    .Trim()
                    .Split('=')[1];

            //2. Version Text의 세번째 값(Build Number)은 2000년 1월 1일부터 Build된 날짜까지의 총 일(Days) 수 이다.
            int intDays = Convert.ToInt32(strVersionText.Split('.')[2]);
            DateTime refDate = new DateTime(2000, 1, 1);
            DateTime dtBuildDate = refDate.AddDays(intDays);

            //3. Verion Text의 네번째 값(Revision NUmber)은 자정으로부터 Build된 시간까지의 지나간 초(Second) 값 이다.
            int intSeconds = Convert.ToInt32(strVersionText.Split('.')[3]);
            intSeconds = intSeconds * 2;
            dtBuildDate = dtBuildDate.AddSeconds(intSeconds);


            //4. 시차조정
            System.Globalization.DaylightTime daylingTime = TimeZone.CurrentTimeZone
                    .GetDaylightChanges(dtBuildDate.Year);
            if (TimeZone.IsDaylightSavingTime(dtBuildDate, daylingTime))
                dtBuildDate = dtBuildDate.Add(daylingTime.Delta);

            string sDate = dtBuildDate.ToString("yyMMdd");
            string sTime = dtBuildDate.ToString("HHmm");

            //5. 변환된 날짜, 시간으로 버전 정보 리턴
            return String.Format("Ver: {0}.{1}.{2}.{3}", version.Major, version.Minor, sDate, sTime);
        }
 
        //protected void SetNowTime()
        //{
        //    try
        //    {
        //        DBHelper helper = new DBHelper(true);

        //        DataSet ds = helper.FillDataSet("Select SYSDATE  ", CommandType.Text);
        //        if (ds.Tables[0].Rows.Count == 1)
        //        {
        //            SetSystemTimeClass s = new SetSystemTimeClass(Convert.ToDateTime(ds.Tables[0].Rows[0][0]));
        //            s.StandardTimeInterval = 9;
        //            s.SetTime();
        //            bSyncTime = false;
        //        }
        //    }
        //    catch (SqlException ex)
        //    {
        //        switch (ex.Number)
        //        {
        //            case 3135:
        //                break;
        //            case 12543:
        //                break;
        //            default:
        //                break;
        //        }
        //    }
        //    catch (Exception e)
        //    {
        //        SetMessage(e.Message);
        //    }
        //}

        private int CheckNetwork()
        {
            try
            {
                int iReturn = 0;
                //uint iLinkQuality = 0;

                foreach (NetworkInterface ni in NetworkInterface.GetAllNetworkInterfaces())
                {
                    if (iReturn != 0)
                        break;

                    switch (ni.NetworkInterfaceType)
                    {
                        case NetworkInterfaceType.Wireless80211:
                        case NetworkInterfaceType.Isdn:
                        case NetworkInterfaceType.Ethernet:
                            if (ni.Name.ToUpper().IndexOf("VMWARE") < 0)
                            {
                                if (ni.OperationalStatus == OperationalStatus.Up)
                                {
                                    iReturn = 1;
                                }
                            }
                            break;
                    }
                }

                return iReturn;
            }
            catch (SqlException ex)
            {
                switch (ex.Number)
                {
                    case 3135:
                        break;
                    case 12543:
                        break;
                    default:
                        break;
                }

                return 0;
            }
            catch (Exception ex)
            {
                SetMessage(ex.Message);
                return 0;
            }
        }

        /// <summary>
        /// 시스템 시간을 DB 시간과 동기화하는지 여부
        /// </summary>
        public bool SyncTime
        {
            get { return bSyncTime; }
            set { bSyncTime = value; }
        }

        /// <summary>
        /// 현재 BaseForm 에 설정된 시간
        /// </summary>
        protected DateTime dNow
        {
            get { return _dTime; }
        }

        public MSComm[] Comm
        {
            get { return _Comm; }
            set { _Comm = value; }
        }

        public int iStartPortNo
        {
            get { return _iStartPortNo; }
            set { _iStartPortNo = value; }
        }

        public int iMaxCnt
        {
            get { return _iMaxCnt; }
            set { _iMaxCnt = value; }
        }

        public void CommStart()
        {
            _Comm = new MSComm[iStartPortNo + iMaxCnt];

            //복수개의 포트를 사용하는경우에는 시작포트번호부터 총갯수만큼 생성한다.
            for (int i = iStartPortNo; i < iStartPortNo + iMaxCnt; i++)
            {
                //시리얼 포트 복수 Instance 생성
                _Comm[i] = new MSComm("COM" + i.ToString(), 9600, System.IO.Ports.Parity.None, 8, System.IO.Ports.StopBits.One, true);
                _Comm[i].ETX = LF;
                _Comm[i].LoopCnt = 10000;
                _Comm[i].PortOpen();

                //이벤트 정의
                _Comm[i].OnCommEvent += new MSComm.DataRecvHandler(OnComm);
                _Comm[i].OnErrorEvent += new MSComm.ErrorEventHandler(OnError);
            }
        }

        public void CommEnd()
        {
            //Port Close
            for (int i = iStartPortNo; i < iStartPortNo + iMaxCnt; i++)
            {
                Comm[i].PortClose();
            }
        }

        #region 데이타 수신 이벤트
        private void OnComm(object sender, SerialClientEventArgs e)
        {

            string Recv_Temp = "";
            string Recv_Data = "";
            string sPortNo = "";
            int iQcPoint = 0;

            try
            {
                Invoke(new EventHandler(delegate
                {

                    sPortNo = e.PortNo.ToString();
                    Recv_Temp = e.StrMessage;

                    //가비지 문자열인경우 Skip
                    if (Recv_Temp.Trim() == "" || Recv_Temp == null) return;

                    //데이타 포멧검정
                    if (Recv_Temp.IndexOf(CR) > 0 || Recv_Temp.IndexOf(LF) > 0)
                    {
                        //Recv_Temp = Recv_Temp.Substring(27, 12); //110.05 61.36
                        Recv_Data = Recv_Temp;
                        //Recv_Data = Convert.ToString(Convert.ToSingle(Recv_Data));

                        //계측기 포트번호 3[L1],4[R1],5[L2],6[R2]로 연결해야함 => 계측기 Point 1,2,3,4 
                        iQcPoint = int.Parse(sPortNo) - (iStartPortNo - 1);
                    }
                    else
                    {
                        return;
                    }

                    //측정값 판정
                    serialDataQueue.Enqueue(Recv_Data);
                    return;

                }));

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                //Port Close
                for (int i = iStartPortNo; i < iStartPortNo + iMaxCnt; i++)
                {
                    Comm[i].PortClose();
                    System.Threading.Thread.Sleep(200);
                    Comm[i].PortOpen();
                }
                return;
            }

        }

        private void OnError(object sender, SerialClientEventArgs e)
        {
            SetMessage(e.ToString());
        }

        #endregion

        private void TimeTimer_Tick(object sender, EventArgs e)
        {
            lblDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            lblTime.Text = DateTime.Now.ToString("HH:mm:ss");

            if (_dTime.Minute != DateTime.Now.Minute)
            {
                bSetRecDate = false;
            }

            if (!bSetRecDate)
            {
                // 시간 분이 변경되면 이벤트로 알림
                if (UpdateMinuteEvent != null)
                {
                    this.UpdateMinuteEvent();
                }
                SetRecDate();
                //10분마다 설비현황에 동작시간 저장
                Common.Set_LastAct();
            }

            _dTime = DateTime.Now;

            if (iMax != 0)
            {
                if (iMax <= iCount)
                {
                    iMax = 0;
                    iCount = 0;
                    lblMessage.Text = Common.LineMsg;
                }

                iCount++;
            }
        }

        private void SetRecDate()
        {
            try
            {
                if (bUseNetwork)
                {
                    string sSQL = "";

                    //sSQL += "Select FN_RECDATE(to_char(sysdate,'yyyymmddhh24miss')) as RECDATE, ";
                    //sSQL += "FN_DAYNIGHT(to_char(sysdate,'yyyymmddhh24miss')) as DayNight ";
                    //sSQL += "FROM dual";
                    sSQL += "Select FN_RECDATE(sysdate) as RECDATE ";
                    sSQL += "FROM dual";

                    DBHelper helper = new DBHelper(true);

                    DataSet ds = helper.FillDataSet(sSQL, CommandType.Text);

                    if (ds.Tables[0].Rows.Count == 1)
                    {
                        Common.gRecDate = ds.Tables[0].Rows[0]["RECDATE"].ToString();
                        //Common.gDayNight = ds.Tables[0].Rows[0]["DayNight"].ToString();

                        bSetRecDate = true;
                    }

                    Common.SetMessageList();
                }
            }
            catch (Exception ex)
            {
                SetMessage(ex.Message);
            }
        }

        /// <summary>
        /// 이벤트 타이머가 발생시키는 이벤트
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected virtual void EventTimer_Tick(object sender, EventArgs e)
        {

        }

        /// <summary>
        /// 이벤트 타이머 작동 여부
        /// </summary>
        public bool EventTimerEnable
        {
            get { return EventTimer.Enabled; }
            set { EventTimer.Enabled = value; }
        }

        /// <summary>
        /// 이벤트 타이머 시간 간격
        /// </summary>
        public int EventTimerInterval
        {
            get { return EventTimer.Interval; }
            set { EventTimer.Interval = value; }
        }

        private void NetworkTimerCheck()
        {
            try
            {
                while (true)
                {
                    int iResult = CheckNetwork();
                    if (iResult == 1)
                    {
                        //lblNetwork.Text = "네트워크 상태\n정상";
                        lblNetwork.BackgroundImage = global::SmartDas.Properties.Resources.네트워크상태_01;
                        lblNetwork.SetColor(Color.DeepSkyBlue);

                        // network 불량 -> 네트워크 정상으로 될때 ip address를 다시 읽어들임 
                        if (bUseNetwork == false)
                        {
                            string sIpAddr = String.Format("IP: {0}", Common.GetIPAddress());
                            if (sIpAddr != Common.IpAddrInfo)
                            {
                                Common.IpAddrInfo = sIpAddr;
                                lblVer_Ip.Text = Common.IpAddrInfo + Environment.NewLine + Common.ProgVersion;
                            }
                        }

                        bUseNetwork = true;
                        clsDB.bUseNetwork = true;

                        //if (bSyncTime)
                        //{
                        //    SetNowTime();
                        //}
                    }
                    else if (iResult == 2)
                    {
                        //lblNetwork.Text = "네트워크 상태\n불량";
                        lblNetwork.BackgroundImage = global::SmartDas.Properties.Resources.네트워크상태_02;
                        lblNetwork.SetColor(Color.YellowGreen);

                        bUseNetwork = true;
                        clsDB.bUseNetwork = true;

                        //if (bSyncTime)
                        //{
                        //    SetNowTime();
                        //}
                    }
                    else
                    {
                        bUseNetwork = false;
                        clsDB.bUseNetwork = false;

                        //lblNetwork.Text = "네트워크 상태\n연결 안됨";
                        lblNetwork.BackgroundImage = global::SmartDas.Properties.Resources.네트워크상태_02;
                        lblNetwork.SetColor(Color.Red);
                    }

                    Thread.Sleep(1000);
                }
            }
            catch (ThreadAbortException TE)
            {
                Console.WriteLine(TE.Message);
                return;
            }
            catch (Exception)
            {
                return;
            }
        }

        public DialogResult ShowDialogForm(Form form)
        {
            DialogResult res;
            bool bTopMost = false;
            TimeTimer.Enabled = false;
            DoProgress();
            bool bPreEventTimerEnable = EventTimerEnable;

            if (th != null)
            {
                th.Abort();
                th = null;
            }

            ClosePrgForm();

            bTopMost = this.TopMost;

#if Debug
            form.TopMost = true;
#endif

            form.Focus();
            form.ShowInTaskbar = false;
            //if (!form.GetType().FullName.Contains("POPUP"))
            //{
            //    this.Visible = false;
            //}
            //this.ShowInTaskbar = false;
            res = form.ShowDialog(this);

            //this.Visible = true;
            //this.TopMost = bTopMost;
            //this.ShowInTaskbar = true;
            //this.TopMost = true;

            lblDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            lblTime.Text = DateTime.Now.ToString("HH:mm:ss");
            ReDrawInfomation();

            TimeTimer.Enabled = true;

            if (th == null)
            {
                th = new Thread(new ThreadStart(NetworkTimerCheck));
                th.IsBackground = true;
                th.Start();
            }

            EventTimerEnable = bPreEventTimerEnable;
            return res;
        }

        public void ShowForm(Form form)
        {
            form.Show();
        }

        private void BaseForm_Activated(object sender, EventArgs e)
        {
            if (!bLoad)
            {
                TimeTimer.Enabled = true;

                if (th == null)
                {
                    th = new Thread(new ThreadStart(NetworkTimerCheck));
                    th.IsBackground = true;
                    th.Start();
                }

                this.Text = lblTitle.Text;

                bLoad = true;
            }
        }

        public void SetMessage(string mes)
        {
            // 임시 오류 내용 막은 근본적인 해결책 필요
            if (mes.IndexOf("스레드가") >= 0)
                return;
            if (mes == "네트워크 상태를 확인하시기 바랍니다.")
            {
                MessageBoxShow("네트워크 상태를 확인하시기 바랍니다.", MessageBoxButtons.OK);
            }

            lblMessage.Text = Common.GetMessage(mes);

            iCount = 0;
            iMax = 10;
        }

        public void SetMessagePos(string mes)
        {
            // 임시 오류 내용 막은 근본적인 해결책 필요
            if (mes.IndexOf("스레드가") >= 0)
                return;
            if (mes == "네트워크 상태를 확인하시기 바랍니다.")
            {
                MessageBoxShow("네트워크 상태를 확인하시기 바랍니다.", MessageBoxButtons.OK);
            }

            lblMessage.Text = Common.GetMessage(mes);
            lblMessage.Position = 100;

            iCount = 0;
            iMax = 10;
        }

        public void SetMessage(string mes, int iSecond)
        {
            if (mes.IndexOf("스레드가") >= 0)
                return;
            lblMessage.Text = Common.GetMessage(mes);
            iCount = 0;
            iMax = iSecond;
        }

        public void SetLineMessage()
        {
            iCount = 0;
            iMax = 10;
        }

        private void BaseForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (th != null)
            {
                th.Abort();
                th = null;
            }
        }

        /// <summary>
        /// 공통코드 정보 가져오기
        /// </summary>
        /// <param name="MajorCode">메이저코드 예) 사업장(PLANTCODE)</param>
        /// <param name="sArr"> ColumnName, Value, ColumnName2, Value2, ... </param>
        /// <returns></returns>
        public DataTable GET_TBM0000_CODE(string MajorCode, string[] sArr = null)
        {
            string methodName = new StackFrame().GetMethod().Name;
            StringBuilder query = null;
            DataTable dt = new DataTable();
            DBHelper helper = new DBHelper(false);

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);

                query.AppendLine(" SELECT MinorCode AS CODE_ID ");
                query.AppendLine("        , '[' + MinorCode + '] '+  CodeName AS CODE_NAME ");
                query.AppendLine("        , RelCode1, RelCode2, RelCode3, RelCode4, RelCode5 ");
                query.AppendLine("        , UseFlag ");
                query.AppendLine("        , DisplayNo ");
                query.AppendLine(" FROM   TBM0000 WITH(NOLOCK) ");
                query.AppendLine(" WHERE  MajorCode = '" + MajorCode + "' ");
                query.AppendLine(" AND    MinorCode <> '$' ");

                if (sArr != null)
                {
                    for (int i = 0; i < sArr.Length; i += 2)
                    {
                        query.AppendLine(" AND  " + sArr[i] + " = '" + sArr[i + 1] + "' ");
                    }
                }

                query.AppendLine(" ORDER BY DisplayNo ");
                dt = helper.FillTable(Convert.ToString(query), CommandType.Text);

                return dt != null ? dt : new DataTable();
            }
            catch (Exception ex)
            {
                SetMessage(ex.ToString());
                return new DataTable();
            }
            finally
            {
                if (query != null) { query = null; }
                helper.Close();
            }
        }

        #region 팝업 ProgressBar 설정
        public virtual void DoProgress()
        {
            this.Cursor = Cursors.WaitCursor;

            UseWaitCursor = true;
            //if (this.bgProcess.IsBusy)
            //    return;

            //this.bgProcess.RunWorkerAsync("처리 중...");
            //this.AutoReset.WaitOne();
        }

        protected void ClosePrgForm()
        {
            this.Cursor = Cursors.Default;

            UseWaitCursor = false;
            //this.IsShowDialog = false;
            //try
            //{
            //    if (this.ProgressForm.InvokeRequired)
            //    {
            //        this.Invoke(new MethodInvoker(delegate
            //        {
            //            Thread.Sleep(200);
            //            this.ProgressForm.Close();
            //        })
            //                    );
            //        return;
            //    }

            //    this.ProgressForm.Close();
            //}
            //catch (Exception ex)
            //{
            //    // To Do : 여기서 어떤 오류가 나는지 확인이 필요.
            //    SetMessage(ex.Message);
            //}
        }

        void bgProcess_DoWork(object sender, DoWorkEventArgs e)
        {
            //ProgressForm = new POPUP.BaseProgressForm(this.Location, this.Width, this.Height);
            //ProgressForm.Activated += new EventHandler(ProgressForm_Activated);
            //ProgressForm.indProgress.SetMessage(e.Argument.ToString());
            //ProgressForm.TopMost = true;
            //ProgressForm.ShowDialog(this);
        }

        void ProgressForm_Activated(object sender, EventArgs e)
        {
            //this.AutoReset.Set();
        }

        public DialogResult MessageBoxShow(string Message, MessageBoxButtons buttons = MessageBoxButtons.OK, string lblTitle = "알   림")
        {
            string mes = Common.GetMessage(Message);
            MessageForm mesForm = new MessageForm(mes, buttons, lblTitle);

            return ShowDialogForm(mesForm);
        }

        public DialogResult MessageBoxShow(string Message, Infragistics.Win.HAlign textAlign, MessageBoxButtons buttons = MessageBoxButtons.OK, string lblTitle = "알   림")
        {
            string mes = Common.GetMessage(Message);
            MessageForm mesForm = new MessageForm(mes, textAlign, buttons, lblTitle);

            return ShowDialogForm(mesForm);
        }

        #endregion

        private void lblImage_DoubleClick(object sender, EventArgs e)
        {
            DialogResult result = MessageBoxShow("종료하시겠습니까?", MessageBoxButtons.OKCancel);

            if (result.Equals(DialogResult.OK))
            {
                Application.Exit();
            }
        }

        private void OnApplicationExit(object sender, EventArgs e)
        {
            LogFile.WriteLog(string.Format("POP 프로그램 종료\r\n"), LogType.PROC);
        }

    }
}