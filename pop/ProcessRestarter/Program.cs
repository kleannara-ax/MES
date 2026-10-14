using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ProcessRestarter
{
    class Program
    {
        static void Main(string[] args)
        {
            string stateString = "RESTARTING [SMART DAS] ";

            for (int i = 0; i < 3; i++)
            {
                System.Console.WriteLine(stateString);

                System.Threading.Thread.Sleep(300);
                stateString += ".";

                System.Console.Clear();
            }

            System.Diagnostics.Process.Start(Environment.CurrentDirectory + "\\SmartDas.exe");

            System.Console.WriteLine("RESTART COMPLETE");
        }
    }
}
