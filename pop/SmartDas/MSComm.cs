using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Timers;
using System.Windows.Forms;

namespace SmartDas
{
    /// <summary>
    /// *----------------------------------------------------------------------------------*
    ///  Name Space   : SAMMI.COMMON.LIB
    ///  Class ID     : MSComm                                                            
    ///  Class Name   : RS232c 통신                                                       
    ///  Created Date :                                                          
    ///  Made By      :                                                             
    ///  Description  : 1)RS232c 통신설정 및 처리                                
    ///  (CopyWrite SAMMI INFORMATION SYSTEM CO.,LTD)
    /// *----------------------------------------------------------------------------------*
    /// </summary>

    /// RemoteClientEventArgs: a custom event inherited from EventArgs.
    /// EventArgs-이벤트 데이터가 들어 있는 클래스에 대한 기본 클래스
    public class SerialClientEventArgs : EventArgs
    {
        private string message;
        private int bytes;
        private EventArgs Arg;
        private string portNo;

        public SerialClientEventArgs(string message, int bytes, string port, SerialDataReceivedEventArgs arg)
        {
            this.message = message;
            this.bytes = bytes;
            this.Arg = arg;
            this.portNo = port;
        }

        //----------------------------------------------
        // 외부에서 사용가능하도록 Properties선언
        // ex)e.StrMessage
        //----------------------------------------------
        public string StrMessage
        {
            get
            { return message; }
        }

        public string PortNo
        {
            get
            { return portNo; }
        }

    }

    public class MSComm
    {
        #region Member선언
        private SerialPort Comm = new SerialPort();

        public enum DataMode { Text, Hex }
        public enum LogMsgType { Incoming, Outgoing, Normal, Warning, Error };


        // Delegate 선언
        public delegate void DataRecvHandler(object from, SerialClientEventArgs e);

        //Delegate이벤트로 사용할 이벤트명 선언
        public event DataRecvHandler OnCommEvent;

        // Error Event
        public delegate void ErrorEventHandler(object sender, SerialClientEventArgs e);
        public event ErrorEventHandler OnErrorEvent;
        #endregion

        #region Properties
        private static int portno = 0;
        private static string etx = "";
        private static string stx = "";
        private static int iloopCnt = 5000;
        private static string sRecvData = string.Empty;
        private System.Timers.Timer tmrWaitData = new System.Timers.Timer();
        private static int tmrInterval = 1000;
        private System.IO.Ports.SerialDataReceivedEventArgs eSDRECV = null;
        private object oSource = null;

        public int PortNo
        {
            get
            { return portno; }
            set
            { portno = value; }
        }

        public string STX
        {
            get
            { return stx; }
            set
            { stx = value; }
        }

        public string ETX
        {
            get
            { return etx; }
            set
            { etx = value; }
        }

        public int LoopCnt
        {
            get
            { return iloopCnt; }
            set
            { iloopCnt = value; }
        }

        public int _tmrInterval
        {
            get
            {
                return tmrInterval;
            }
            set
            {
                tmrInterval = value;
            }
        }

        #endregion

        #region 생성자

        public MSComm()
        {
            try
            {
                //
                // TODO: 여기에 생성자 논리를 추가합니다.
                //

                Comm.PortName = "COM" + portno.ToString();
                Comm.BaudRate = 4800;
                Comm.Parity = System.IO.Ports.Parity.None;
                Comm.DataBits = 8;
                Comm.StopBits = System.IO.Ports.StopBits.One;

                Comm.DataReceived += new SerialDataReceivedEventHandler(Comm_ReceivedEvent);

            }
            catch (System.Exception ex)
            {
                throw new SystemException("통신연결 실패!", ex);
            }
        }

        public MSComm(int Port)
        {
            try
            {
                //
                // TODO: 여기에 생성자 논리를 추가합니다.
                //
                portno = Port;
                Comm.PortName = "COM" + portno.ToString();
                Comm.BaudRate = 4800;
                Comm.Parity = System.IO.Ports.Parity.None;
                Comm.DataBits = 8;
                Comm.StopBits = System.IO.Ports.StopBits.One;

                Comm.DataReceived += new SerialDataReceivedEventHandler(Comm_ReceivedEvent);

            }
            catch (System.Exception ex)
            {
                throw new SystemException("통신연결 실패!", ex);
            }
        }

        public MSComm(string _port, int _baudRate, System.IO.Ports.Parity _parity, int _dataBits, System.IO.Ports.StopBits _stopBits)
        {
            this.Comm = new SerialPort(_port, _baudRate, _parity, _dataBits, _stopBits);
            Comm.DataReceived += new SerialDataReceivedEventHandler(Comm_ReceivedEvent);
        }

        public MSComm(string _port, int _baudRate, System.IO.Ports.Parity _parity, int _dataBits, System.IO.Ports.StopBits _stopBits, bool DTR)
        {
            this.Comm = new SerialPort(_port, _baudRate, _parity, _dataBits, _stopBits);
            this.Comm.DtrEnable = DTR;
            Comm.DataReceived += new SerialDataReceivedEventHandler(Comm_ReceivedEvent);
        }

        /// <summary>
        /// 시리얼 통신 생성자 타입 지정 가능
        /// </summary>
        /// <param name="_port">통신포트</param>
        /// <param name="_baudRate">통신속도</param>
        /// <param name="_parity">패러티비트</param>
        /// <param name="_dataBits">데이터비트</param>
        /// <param name="_stopBits">정지비트</param>
        /// <param name="DTR">DTR모드 사용 여부</param>
        /// <param name="sType">COM 데이터 수신 처리 모드(T : timer, E : ETX, R : 정규식)</param>
        public MSComm(string _port, int _baudRate, System.IO.Ports.Parity _parity, int _dataBits, System.IO.Ports.StopBits _stopBits, bool DTR, string sType)
        {
            this.Comm = new SerialPort(_port, _baudRate, _parity, _dataBits, _stopBits);
            this.Comm.DtrEnable = DTR;

            switch (sType)
            {
                case "T":
                    Comm.DataReceived += new SerialDataReceivedEventHandler(Comm_ReceivedTmrEvent);
                    break;
                case "R":
                    Comm.DataReceived += new SerialDataReceivedEventHandler(Comm_ReceivedRegEvent);
                    break;
                case "E":
                    Comm.DataReceived += new SerialDataReceivedEventHandler(Comm_ReceivedEvent);
                    break;
                case "S":
                    Comm.DataReceived += new SerialDataReceivedEventHandler(Comm_ReceivedStanbyEvent);
                    break;
            }

        }
        #endregion

        #region RS232통신설정

        public void ExtraInitTimer()
        {
            // Set the timer interval to one second
            tmrWaitData.Interval = tmrInterval;

            // Attach the timer tick event handler
            tmrWaitData.Elapsed += new ElapsedEventHandler(tmrWaitData_Elapsed);
        }


        /// <summary>
        /// 포트가 열려있으면 닫는다.
        /// </summary>
        /// <returns></returns>
        public bool PortOpen()
        {
            //포트가 닫혀있으면 포트를 연다.
            try
            {
                if (!Comm.IsOpen)
                {
                    Comm.Open();
                }
            }
            catch
            {
                return false;
            }

            return Comm.IsOpen;
        }

        /// <summary>
        /// 포트의 상태 확인 (True:열림/False:닫힘)
        /// </summary>
        private bool IsOpen
        {
            get
            {
                return Comm.IsOpen;
            }
        }


        /// <summary>
        /// 포트가 열려있으면 포트를 닫는다.
        /// </summary>
        /// <returns></returns>
        public bool PortClose()
        {
            //포트가 열려있으면 포트를 닫는다.
            try
            {
                if (Comm.IsOpen)
                    Comm.Close();
                return true;
            }
            catch
            {
                return false;
            }
        }


        #endregion ===================================================================================================

        #region Data Receive 이벤트
        public void Comm_ReceivedRegEvent(object source, System.IO.Ports.SerialDataReceivedEventArgs e)
        {
            try
            {
                if (Comm.ReadBufferSize > 0)
                {
                    sRecvData += Comm.ReadExisting();

                    Regex r = new Regex(STX + ".*?" + ETX);

                    for (Match m = r.Match(sRecvData); m.Success; m = m.NextMatch())
                    {
                        this.Comm.DiscardInBuffer();
                        OnCommEvent(source, new SerialClientEventArgs(sRecvData, sRecvData.Length, Comm.PortName.Substring(3), e));
                        sRecvData = string.Empty;
                    }

                }
            }
            catch (Exception ex)
            {
                if (OnErrorEvent != null) OnErrorEvent(this, new SerialClientEventArgs(ex.Message.ToString(), 0, Comm.PortName.Substring(3), e));
            }
        }

        public void Comm_ReceivedTmrEvent(object source, System.IO.Ports.SerialDataReceivedEventArgs e)
        {
            try
            {
                if (Comm.ReadBufferSize != 0)
                {
                    if (e.EventType == System.IO.Ports.SerialData.Chars)
                    {
                        sRecvData += Comm.ReadExisting();

                        eSDRECV = e;
                        oSource = source;

                        //수신버퍼 Clear
                        this.Comm.DiscardInBuffer();

                        tmrWaitData.Stop();
                        tmrWaitData.Start();
                    }
                }
            }
            catch (Exception ex)
            {
                if (OnErrorEvent != null) OnErrorEvent(this, new SerialClientEventArgs(ex.Message.ToString(), 0, Comm.PortName.Substring(3), e));
            }
        }

        public void Comm_ReceivedEvent(object source, System.IO.Ports.SerialDataReceivedEventArgs e)
        {
            try
            {
                string Recv_Temp = "";
                int err_chk = 0;

                if (this.Comm.ReadBufferSize != 0)
                {
                    if (e.EventType == System.IO.Ports.SerialData.Chars)
                    {
                        System.Threading.Thread.Sleep(100);

                        do
                        {
                            Recv_Temp += Comm.ReadExisting();
                            err_chk += 1;
                            Application.DoEvents();
                            if (Recv_Temp.IndexOf(etx) > -1) break;

                            // 수신버퍼의 데이타가 여러패킷으로 나누어 들어오기 때문에
                            // 종결문자가 아직없고 loop횟수가 0000번 이하인경우에만 loop돌아서
                            // 데이타를 취합함.
                        } while ((Recv_Temp.IndexOf(etx) == -1) && (err_chk < iloopCnt));

                        //수신버퍼 Clear
                        this.Comm.DiscardInBuffer();
                        OnCommEvent(source, new SerialClientEventArgs(Recv_Temp, Recv_Temp.Length, Comm.PortName.Substring(3), e));

                        //String일때
                        //if (CurrentDataMode == DataMode.Text)
                        //{
                        //Read all the data waiting in the buffer
                        //string data = Comm.ReadExisting();
                        //Display the text to the user in the terminal
                        //Log(LogMsgType.Incoming, data);
                        //}
                        //바이트일때
                        //else
                        //{
                        ////Obtain the number of bytes waiting in the port's buffer
                        //int bytes = Comm.BytesToRead;

                        ////Create a byte array buffer to hold the incoming data
                        //byte[] buffer = new byte[bytes];

                        ////Read the data from the port and store it in our buffer
                        //Comm.Read(buffer, 0, bytes);

                        ////Show the user the incoming data in hex format
                        ////Log(LogMsgType.Incoming, ByteArrayToHexString(buffer));
                        //}
                    }

                    //2)다른방법
                    //if (e.EventType == System.IO.Ports.SerialData.Chars)

                    //    System.Threading.Thread.Sleep(100);

                    //// 데이터 수신일때

                    //// 끝까지 수신할때까지 기다림

                    //byte[] bReceive = null; // 수신 받을 배열 선언 및 초기화
                    //bReceive = new byte[Comm.ReadBufferSize];
                    //int iReceive;           // 수신크기 받을 변수 선언

                    //// 데이터 수신
                    //iReceive = Comm.Read(bReceive, 0, Comm.ReadLine);

                    //// 바이트배열 값을 스트링으로 변경
                    //ASCIIEncoding AE = new ASCIIEncoding();
                    //sData = AE.GetString(bReceive, 0, bReceive.Length);

                    //this._readData = sData;



                    //this._readData = sData.Replace("\r\n", "").ToString();
                    //ScanDataReceive(this, this.Args);
                }

            }
            catch (Exception ex)
            {
                if (OnErrorEvent != null) OnErrorEvent(this, new SerialClientEventArgs(ex.Message.ToString(), 0, Comm.PortName.Substring(3), e));
            }
        }

        public void Comm_ReceivedStanbyEvent(object source, System.IO.Ports.SerialDataReceivedEventArgs e)
        {
            try
            {
                if (this.Comm.ReadBufferSize != 0)
                {
                    if (e.EventType == System.IO.Ports.SerialData.Chars)
                        System.Threading.Thread.Sleep(tmrInterval);

                    // 데이터 수신일때

                    // 끝까지 수신할때까지 기다림

                    byte[] bReceive = null; // 수신 받을 배열 선언 및 초기화
                    bReceive = new byte[Comm.ReadBufferSize];
                    int iReceive;           // 수신크기 받을 변수 선언

                    // 데이터 수신
                    iReceive = Comm.Read(bReceive, 0, Comm.ReadBufferSize);

                    // 바이트배열 값을 스트링으로 변경
                    ASCIIEncoding AE = new ASCIIEncoding();
                    string sData = AE.GetString(bReceive, 0, bReceive.Length);
                    //수신버퍼 Clear
                    this.Comm.DiscardInBuffer();
                    OnCommEvent(source, new SerialClientEventArgs(sData, sData.Length, Comm.PortName.Substring(3), e));

                }

            }
            catch (Exception ex)
            {
                if (OnErrorEvent != null) OnErrorEvent(this, new SerialClientEventArgs(ex.Message.ToString(), 0, Comm.PortName.Substring(3), e));
            }
        }
        private void tmrWaitData_Elapsed(object sender, ElapsedEventArgs e)
        {
            //수신버퍼 Clear
            this.Comm.DiscardInBuffer();
            OnCommEvent(oSource, new SerialClientEventArgs(sRecvData, sRecvData.Length, Comm.PortName.Substring(3), eSDRECV));

            sRecvData = string.Empty;
            tmrWaitData.Stop();
        }


        #endregion

        #region Method
        /// <summary> Send the user's data currently entered in the 'send' box.</summary>
        public void SendData(string SendData)
        {
            if (CurrentDataMode == DataMode.Text)
            {
                //Create an ASCII encoding variable
                Encoding ascii = Encoding.ASCII;
                //Create an Unicode variable
                Encoding unicode = Encoding.Unicode;

                //Convert the string into a byte[]
                byte[] unicodeBytes = unicode.GetBytes(SendData);

                //Perform the conversion from one encoding to the other
                byte[] asciiBytes = Encoding.Convert(unicode, ascii, unicodeBytes);

                //Convert the new byte[] into a char[] and then into a string.
                //This is a slightly different approach to converting to illustrate
                //the use of GetCharCount/GetChars
                char[] asciiChar = new char[ascii.GetCharCount(asciiBytes, 0, asciiBytes.Length)];
                ascii.GetChars(asciiBytes, 0, asciiBytes.Length, asciiChar, 0);

                string sNEW = new string(asciiChar);
                //Send the user's text straight out the port
                Comm.WriteLine(sNEW);
                //Show in the terminal window the user's text
                Log(LogMsgType.Outgoing, "txtSendData.Text" + "\n");
            }
            else
            {
                try
                {
                    //Convert the user's string of hex digits (ex: B4 CA E2) to a byte array
                    byte[] data = HexStringToByteArray(SendData);

                    //Send the binary data out the port
                    Comm.Write(data, 0, data.Length);

                    //Show the hex digits on in the terminal window
                    Log(LogMsgType.Outgoing, ByteArrayToHexString(data) + "\n");
                }
                catch (FormatException)
                {
                    //Inform the user if the hex string was not properly formatted
                    Log(LogMsgType.Error, "Not properly formatted hex string: " + "txtSendData.Text" + "\n");
                }
            }
            //txtSendData.SelectAll();
        }

        /// <summary> Log data to the terminal window. </summary>
        /// <param name="msgtype"> The type of message to be written. </param>
        /// <param name="msg"> The string containing the message to be shown. </param>
        private void Log(LogMsgType msgtype, string msg)
        {
            //rtfTerminal.Invoke(new EventHandler(delegate
            //{
            //rtfTerminal.SelectedText = string.Empty;
            //rtfTerminal.SelectionFont = new Font(rtfTerminal.SelectionFont, FontStyle.Bold);
            //rtfTerminal.SelectionColor = LogMsgTypeColor[(int)msgtype];
            //rtfTerminal.AppendText(msg);
            //rtfTerminal.ScrollToCaret();
            //}));
        }

        /// <summary> Convert a string of hex digits (ex: E4 CA B2) to a byte array. </summary>
        /// <param name="s"> The string containing the hex digits (with or without spaces). </param>
        /// <returns> Returns an array of bytes. </returns>
        private byte[] HexStringToByteArray(string s)
        {
            s = s.Replace(" ", "");
            byte[] buffer = new byte[s.Length / 2];
            for (int i = 0; i < s.Length; i += 2)
                buffer[i / 2] = (byte)Convert.ToByte(s.Substring(i, 2), 16);

            return buffer;
        }

        /// <summary> Converts an array of bytes into a formatted string of hex digits (ex: E4 CA B2)</summary>
        /// <param name="data"> The array of bytes to be translated into a string of hex digits. </param>
        /// <returns> Returns a well formatted string of hex digits with spacing. </returns>
        private string ByteArrayToHexString(byte[] data)
        {
            StringBuilder sb = new StringBuilder(data.Length * 3);
            foreach (byte b in data)
                sb.Append(Convert.ToString(b, 16).PadLeft(2, '0').PadRight(3, ' '));

            return sb.ToString().ToUpper();
        }

        public DataMode CurrentDataMode
        {
            get
            {
                //if (rbHex.Checked)
                //    return DataMode.Hex;
                //else
                return DataMode.Text;
            }
            set
            {
                //if (value == DataMode.Text)
                //    rbText.Checked = true;
                //else
                //    rbHex.Checked = true;
            }
        }
        #endregion

    }
}
