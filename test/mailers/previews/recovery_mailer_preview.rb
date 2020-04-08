# Preview all emails at http://localhost:3000/rails/mailers/recovery_mailer
class RecoveryMailerPreview < ActionMailer::Preview
  def new_recovery_email
    RecoveryMailer.with(email: 'teste@test.com',
                        tokens: { csrf: 'placeholder',
                                 access: 'placeholder' } )
      .new_recovery_email
  end
end
