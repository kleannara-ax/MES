using SmartDas.Components;

namespace SmartDas
{
    partial class DASMain
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
            this.components = new System.ComponentModel.Container();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.label1 = new System.Windows.Forms.Label();
            this.txtOPName = new SmartDas.Components.MESLabel();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.label2 = new System.Windows.Forms.Label();
            this.txtOPGrpName = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.txtUserName = new SmartDas.Components.MESLabel();
            this.bBoxMachine = new SmartDas.Components.ButtonBox();
            this.label4 = new System.Windows.Forms.Label();
            this.txtMachName = new SmartDas.Components.MESLabel();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "설비 선택";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.txtMachName);
            this.GroupBody.Controls.Add(this.label4);
            this.GroupBody.Controls.Add(this.bBoxMachine);
            this.GroupBody.Controls.Add(this.txtUserName);
            this.GroupBody.Controls.Add(this.label3);
            this.GroupBody.Controls.Add(this.txtOPGrpName);
            this.GroupBody.Controls.Add(this.label2);
            this.GroupBody.Controls.Add(this.bBox1);
            this.GroupBody.Controls.Add(this.label1);
            this.GroupBody.Controls.Add(this.txtOPName);
            // 
            // timer1
            // 
            this.timer1.Interval = 20000;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(10, 76);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(165, 60);
            this.label1.TabIndex = 47;
            this.label1.Text = "공       정";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtOPName
            // 
            this.txtOPName.BackColor = System.Drawing.Color.White;
            this.txtOPName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.txtOPName.ColorContent = System.Drawing.Color.Transparent;
            this.txtOPName.ColorLabel = System.Drawing.Color.White;
            this.txtOPName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtOPName.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtOPName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.txtOPName.Location = new System.Drawing.Point(183, 76);
            this.txtOPName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.txtOPName.MoveControl = null;
            this.txtOPName.Name = "txtOPName";
            this.txtOPName.Size = new System.Drawing.Size(276, 60);
            this.txtOPName.TabIndex = 46;
            this.txtOPName.TextHAlign = Infragistics.Win.HAlign.Left;
            this.txtOPName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.Transparent;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 20.25F;
            this.bBox1.Location = new System.Drawing.Point(923, 10);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(346, 126);
            this.bBox1.TabIndex = 48;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(10, 10);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(165, 60);
            this.label2.TabIndex = 49;
            this.label2.Text = "공 정 그 룹";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtOPGrpName
            // 
            this.txtOPGrpName.BackColor = System.Drawing.Color.White;
            this.txtOPGrpName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.txtOPGrpName.ColorContent = System.Drawing.Color.Transparent;
            this.txtOPGrpName.ColorLabel = System.Drawing.Color.White;
            this.txtOPGrpName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtOPGrpName.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtOPGrpName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.txtOPGrpName.Location = new System.Drawing.Point(182, 10);
            this.txtOPGrpName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.txtOPGrpName.MoveControl = null;
            this.txtOPGrpName.Name = "txtOPGrpName";
            this.txtOPGrpName.Size = new System.Drawing.Size(276, 60);
            this.txtOPGrpName.TabIndex = 50;
            this.txtOPGrpName.TextHAlign = Infragistics.Win.HAlign.Left;
            this.txtOPGrpName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(466, 10);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(165, 60);
            this.label3.TabIndex = 51;
            this.label3.Text = "사 용 자";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtUserName
            // 
            this.txtUserName.BackColor = System.Drawing.Color.White;
            this.txtUserName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.txtUserName.ColorContent = System.Drawing.Color.Transparent;
            this.txtUserName.ColorLabel = System.Drawing.Color.White;
            this.txtUserName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtUserName.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtUserName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.txtUserName.Location = new System.Drawing.Point(639, 10);
            this.txtUserName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.txtUserName.MoveControl = null;
            this.txtUserName.Name = "txtUserName";
            this.txtUserName.Size = new System.Drawing.Size(275, 60);
            this.txtUserName.TabIndex = 52;
            this.txtUserName.TextHAlign = Infragistics.Win.HAlign.Left;
            this.txtUserName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // bBoxMachine
            // 
            this.bBoxMachine.BackColor = System.Drawing.Color.Thistle;
            this.bBoxMachine.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBoxMachine.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBoxMachine.CountX = 1;
            this.bBoxMachine.CountY = 1;
            this.bBoxMachine.CurrentPage = 0;
            this.bBoxMachine.ExTag = "";
            this.bBoxMachine.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold);
            this.bBoxMachine.FontSize = 20.25F;
            this.bBoxMachine.Location = new System.Drawing.Point(10, 145);
            this.bBoxMachine.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBoxMachine.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBoxMachine.Name = "bBoxMachine";
            this.bBoxMachine.SelectCommand = null;
            this.bBoxMachine.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBoxMachine.SelectProcedureName = null;
            this.bBoxMachine.Size = new System.Drawing.Size(1256, 300);
            this.bBoxMachine.TabIndex = 53;
            this.bBoxMachine.buttonChangeEvent += new SmartDas.Components.ButtonBox.ButtonChange(this.bBoxMachine_buttonChangeEvent);
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(467, 76);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(165, 60);
            this.label4.TabIndex = 55;
            this.label4.Text = "설       비";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtMachName
            // 
            this.txtMachName.BackColor = System.Drawing.Color.White;
            this.txtMachName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.txtMachName.ColorContent = System.Drawing.Color.Transparent;
            this.txtMachName.ColorLabel = System.Drawing.Color.White;
            this.txtMachName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtMachName.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtMachName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.txtMachName.Location = new System.Drawing.Point(640, 76);
            this.txtMachName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.txtMachName.MoveControl = null;
            this.txtMachName.Name = "txtMachName";
            this.txtMachName.Size = new System.Drawing.Size(276, 60);
            this.txtMachName.TabIndex = 56;
            this.txtMachName.TextHAlign = Infragistics.Win.HAlign.Left;
            this.txtMachName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // DASMain
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "DASMain";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.DASMain_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Timer timer1;
        private MESLabel txtOPGrpName;
        private System.Windows.Forms.Label label2;
        private ButtonBox bBox1;
        private System.Windows.Forms.Label label1;
        private MESLabel txtOPName;
        private MESLabel txtUserName;
        private System.Windows.Forms.Label label3;
        private ButtonBox bBoxMachine;
        private MESLabel txtMachName;
        private System.Windows.Forms.Label label4;

    }
}
