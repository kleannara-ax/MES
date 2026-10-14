using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SmartDas.POPUP
{
    public partial class BaseProgressForm : Form
    {
        public BaseProgressForm()
        {
            InitializeComponent();
        }

        public BaseProgressForm(Point locpoint, int width, int height)
        {
            InitializeComponent();
            this.Location = new Point(locpoint.X + (width - this.Width) / 2
                                     ,locpoint.Y + (height - this.Height) / 2);
        }

        private void BaseProgressForm_Load(object sender, EventArgs e)
        {
            this.indProgress.Start();
        }
    }
}
