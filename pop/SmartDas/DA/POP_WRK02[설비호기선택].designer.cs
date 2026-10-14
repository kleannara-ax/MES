using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK02
    {
        /// <summary>
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다.
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마십시오.
        /// </summary>
        private void InitializeComponent()
        {
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.bMachine = new SmartDas.Components.ButtonBox();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "타이틀";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.splitContainer1);
            // 
            // btnRightPage
            // 
            this.btnRightPage.LinkButtonBox = this.bMachine;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkButtonBox = this.bMachine;
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.IsSplitterFixed = true;
            this.splitContainer1.Location = new System.Drawing.Point(1, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.bMachine);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 0;
            // 
            // bMachine
            // 
            this.bMachine.BackColor = System.Drawing.Color.Transparent;
            this.bMachine.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bMachine.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bMachine.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bMachine.CountX = 1;
            this.bMachine.CountY = 1;
            this.bMachine.CurrentPage = 0;
            this.bMachine.Dock = System.Windows.Forms.DockStyle.Fill;
            this.bMachine.ExTag = "";
            this.bMachine.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bMachine.FontSize = 24F;
            this.bMachine.Location = new System.Drawing.Point(0, 0);
            this.bMachine.MarginIn = new System.Windows.Forms.Padding(3);
            this.bMachine.MarginOut = new System.Windows.Forms.Padding(3);
            this.bMachine.Name = "bMachine";
            this.bMachine.SelectCommand = null;
            this.bMachine.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bMachine.SelectProcedureName = null;
            this.bMachine.Size = new System.Drawing.Size(1274, 789);
            this.bMachine.TabIndex = 161;
            this.bMachine.buttonChangeEvent += new SmartDas.Components.ButtonBox.ButtonChange(this.bMachine_buttonChangeEvent);
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.MidnightBlue;
            this.bBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 24F;
            this.bBox1.Location = new System.Drawing.Point(0, 0);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(1274, 81);
            this.bBox1.TabIndex = 65;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // POP_WRK02
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK02";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK02_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private ButtonBox bMachine;



    }
}
