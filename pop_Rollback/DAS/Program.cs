#region < HEADER AREA >
// *---------------------------------------------------------------------------------------------*
//   PROJECT 명     : 
//   Created Date   : 2012.03.16
//   Made By        : SAMMI INFORMATION SYSTEM CO.,LTD
//   Description    : 
//   StoreProcedure : 
// *---------------------------------------------------------------------------------------------*
#endregion

#region < USING AREA >
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Reflection;
using System.Windows.Forms;
using System.Diagnostics;
using System.Runtime.InteropServices;
using SAMMI;
using System.IO;
using System.Runtime.CompilerServices;
using Infragistics.Win.UltraWinGrid;

//using SmartSiteTerminal;
using SmartDas;
using System.Data;

#endregion

namespace DAS
{
    static class Program
    {
        [DllImport("user32.dll")]
        public static extern void BringWindowToTop(IntPtr hWnd);

        [DllImport("User32", EntryPoint = "SetForegroundWindow")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("User32")]
        private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        /// <summary>
        /// 해당 응용 프로그램의 주 진입점입니다.
        /// </summary>
        /// 
        [STAThread]
        static void Main(string[] args)
        {
            Configuration appConfig;

            string userid = string.Empty;
            string userName = string.Empty;
            string plantcode = string.Empty;
            string startForm = string.Empty;

            try
            {
                // 동일프로그램 실행 확인(동일프로그램일 경우, 실행중인 프로그램을 맨앞으로 가지고 온다.)
                appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                // RESTART인 경우, 로그인을 하지 않고 시작
//#if !DEBUG
//                if (Program.CheckMultiProcess()) return;
//#endif

                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);

                if (Convert.ToString(appConfig.AppSettings.Settings["STATUS"].Value) == "START")
                {
                    #region 라이브 업데이트
                    ////라이브 업데이트 미사용 차후 별도 방안으로 업데이트 진행
                    //if (Convert.ToString(appConfig.AppSettings.Settings["MODE"].Value).ToUpper() != "DEBUG")
                    //{
                    //    // 라이브 업데이트시 LOCK이 걸린 경우 RESTART   
                    //    DBHelper helper = new DBHelper();
                    //    List<string> list = new List<string>();
                    //    DataTable dt = new DataTable();
                    //    dt = helper.FillTable("SELECT FileID FROM TSY2200 WHERE SystemID = 'SmartDas'");

                    //    if (dt.Rows.Count > 0)
                    //    {
                    //        for (int i = 0; i < dt.Rows.Count; i++)
                    //            list.Add(dt.Rows[i]["FileID"].ToString());

                    //        for (int i = 0; i < list.Count; i++)
                    //        {
                    //            if (File.Exists(Application.StartupPath + "\\" + list[i]))
                    //            {

                    //                helper = new DBHelper();
                    //                Assembly assembly = Assembly.LoadFrom(list[i]);
                    //                Version ver = assembly.GetName().Version;
                    //                try
                    //                {
                    //                    String serverVer = helper.ExecuteScalar("SELECT FileVer FROM TSY2200 WHERE FileID = '" + list[i] + "' AND SystemID = 'SmartDas'").ToString();
                    //                    if (ver.ToString().CompareTo(serverVer) < 0)
                    //                    {
                    //                        SAMMI.Forms.UpgradeForm zz0100 = new SAMMI.Forms.UpgradeForm(userid, global::SmartDas.Properties.Resources.loading_img);
                    //                        try
                    //                        {
                    //                            //AutoClosingMessageBox.Show("Text", "Caption", 1000);
                    //                            //MessageBox.Show("프로그램 구성이 바뀌었습니다. 재실행하겠습니다.");
                    //                            System.Diagnostics.Process.Start(Application.StartupPath + "\\ProcessRestarter.exe");
                    //                            Environment.Exit(0);
                    //                        }
                    //                        catch (ArgumentException ex)
                    //                        {
                    //                            string sExMessage = ex.Message;
                    //                            throw;
                    //                        }
                    //                    }
                    //                }
                    //                catch (Exception ex)
                    //                {
                    //                    MessageBox.Show("Program Update Error!!\n" + ex.Message, "경고");
                    //                }
                    //                finally
                    //                {
                    //                    helper.Close();
                    //                }
                    //            }
                    //            else
                    //            {
                    //                SAMMI.Forms.UpgradeForm zz0100 = new SAMMI.Forms.UpgradeForm(userid, global::SmartDas.Properties.Resources.loading_img);
                    //                try
                    //                {
                    //                    //AutoClosingMessageBox.Show("Text", "Caption", 1000);
                    //                    //MessageBox.Show("프로그램 구성이 바뀌었습니다. 재실행하겠습니다.");
                    //                    System.Diagnostics.Process.Start(Application.StartupPath + "\\ProcessRestarter.exe");
                    //                    Environment.Exit(0);
                    //                }
                    //                catch (ArgumentException ex)
                    //                {
                    //                    string sExMessage = ex.Message;
                    //                    throw;
                    //                }
                    //            }
                    //        }
                    //    }
                    //}
                    #endregion

                    string sPass = string.Empty;
                    if (args.Length == 3)
                    {
                        userid = args[0];
                        sPass = args[1];
                    }
                }
                else
                {
                    appConfig.AppSettings.Settings["STATUS"].Value = "START";
                    appConfig.Save();
                    userid = Convert.ToString(appConfig.AppSettings.Settings["LOGINID"].Value);
                }
                RunApplication(new string[] { userid, userName });
            }
            catch(Exception ex)
            {
                MessageBox.Show("Program Starter Error!!\n" + ex.Message, "경고");
            }
        }
        /// <summary>
        /// 중복프로그램 실행 확인
        /// </summary>
        /// <returns></returns>
        public static Boolean CheckMultiProcess()
        {
            int thisID = System.Diagnostics.Process.GetCurrentProcess().Id; // 현재 기동한 프로그램 id

            //실행중인 프로그램중 현재 기동한 프로그램과 같은 프로그램들 수집
            System.Diagnostics.Process[] p = System.Diagnostics.Process.GetProcessesByName(System.Diagnostics.Process.GetCurrentProcess().ProcessName);

            if (p.Length > 1)
            {
                for (int i = 0; i < p.Length; i++)
                {
                    if (p[i].Id == thisID) continue;

                    ShowWindow(p[i].MainWindowHandle, 1);
                    BringWindowToTop(p[i].MainWindowHandle);
                    SetForegroundWindow(p[i].MainWindowHandle);

                    break;
                }
                return true;
            }

            return false;
        }

        /// <summary>
        /// APPLICATION 실행
        /// </summary>
        /// <param name="args"></param>
        public static void RunApplication(params object[] args)
        {
            Assembly assembly;
            Type typeForm;
            Form newForm;
            string sForm = string.Empty;
            Configuration appconfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);


            //2022 02 23 KKY
            //시작화면 조회시 프로스저를 통하여 검색하도록 수정
            try
            {
                #region 시작화면 지정
                //기존 테이블 미사용으로 인한 주석처리
                DBHelper helper = new DBHelper();
                try
                {
                    System.Data.DataTable dt = helper.FillTable("POP_STR001_S1", CommandType.StoredProcedure
                                                                , helper.CreateParameter("p_IPADDRESS", SAMMI.Common.GetIPAddress(), DbType.String, ParameterDirection.Input));
                    if (dt.Rows.Count < 1)
                    {
                        //SAMMI.Forms.DialogForm dg = new SAMMI.Forms.DialogForm("현장단말 연결정보가 존재하지 않습니다. 관리자프로그램에서 설정 후 재시작하여 주십시오", DialogForm.DialogType.OK);
                        //dg.ShowDialog();
                        if (dt.Rows[0]["PROC_CD"].ToString().Equals("ERR"))
                        {
                            MessageBox.Show("현장단말 연결정보가 존재하지 않습니다. 관리자프로그램에서 설정 후 재시작하여 주십시오");
                            return;
                        }
                        ////sForm = (string)args[3];
                        //if (!string.IsNullOrEmpty(appconfig.AppSettings.Settings["STARTFORM"].Value.ToString()))
                        //    sForm = appconfig.AppSettings.Settings["STARTFORM"].Value.ToString();
                        //else
                        //{
                        //    SAMMI.Forms.DialogForm dg = new SAMMI.Forms.DialogForm("현장단말 연결정보가 존재하지 않습니다. 관리자프로그램에서 설정 후 재시작하여 주십시오", DialogForm.DialogType.OK);
                        //    dg.ShowDialog();
                        //    return;
                        //}
                    }
                    else
                    {
                        sForm = dt.Rows[0][0].ToString();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Program StartPage Error!!\n" + ex.Message + "\n" + SAMMI.Common.GetIPAddress(), "경고");
                }
                finally
                {
                    helper.Close();
                }
                #endregion

                //sForm = appconfig.AppSettings.Settings["STARTFORM"].Value.ToString();
                assembly = Assembly.LoadFrom(Application.StartupPath + @"\" + appconfig.AppSettings.Settings["STARTFORMFILE"].Value.ToString());
                typeForm = assembly.GetType(sForm, true);
                //newForm = (Form)Activator.CreateInstance(typeForm, args[0], args[1], args[2]);

                //2018 05 02 HJH
                //LogFile.WriteLog("POP Program Start (" + sForm + ")", LogType.PROC);
                newForm = (Form)Activator.CreateInstance(typeForm);
                Application.Run(newForm);
                //LogFile.WriteLog("POP Program Close", LogType.PROC);
            }
            catch (Exception ex)
            {
                //SAMMI.Forms.DialogForm dg = new SAMMI.Forms.DialogForm(ex + "시작 화면 설정 오류가 발생하였습니다. 관리자에 문의 하여 주십시오", DialogForm.DialogType.OK);
                //dg.ShowDialog();
                MessageBox.Show(ex + "시작 화면 설정 오류가 발생하였습니다. 관리자에 문의 하여 주십시오");
                return;
            }
        }
    }
}
