using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Windows.Forms;
using System.Reflection;
using System.Runtime.InteropServices;

namespace SmartDas
{
    static class Program
    {
         /// <summary>
        /// 해당 응용 프로그램의 주 진입점입니다.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            DASMain dasMain = new DASMain(args[0], args[1], args[2]);
            Application.Run(dasMain);
        }
        // Hello World
    }
}
