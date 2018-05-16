require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'sinatra/json'
require './image_uploader.rb'
require './models'

enable :sessions


get '/' do
    @users = User.all
    @reviews = Review.all
    @lessons = Lesson.all
    @universities = University.all
 
  erb :index
end

#-----------------会員情報----------------------
get '/signin' do
    erb :sign_in
end

get '/signup' do
    erb :sign_up
end

post '/signin' do
   user = User.find_by(mail: params[:mail]) 
   if user && user.authenticate(params[:password])
       session[:user] = user.id
   end
   redirect '/'
end

post '/signup' do
    if  University.find_by({university: params[:university], course: params[:course]}) == nil
        @university = University.create({
       university: params[:university], course: params[:course]
         })
         @university_id = @university.id
    else
     @university = University.find_by({
       university: params[:university], course: params[:course]
         })
    @university_id = @university.id
    end
     
   @user = User.create({name: params[:name], university_id: @university_id, grade: params[:grade], sex: params[:sex],line_id: params[:line_id], mail: params[:mail], password: params[:password],
    password_confirmation: params[:password_confirmation]})
   if @user.persisted?
       session[:user] = @user.id
   end
   redirect '/'
end

get '/signout' do
   session[:user] = nil
   redirect'/'
end

post '/acount_edit/:id' do
    @user = User.find(session[:user])
    @university = University.find( @user.university_id )
    erb :edit
end

post '/acount_renew/:id' do
    @user = User.find(params[:id])
    @university = University.find( @user.university_id )
    if  University.find_by({university: params[:university], course: params[:course]}) == nil
        @university = University.create({
       university: params[:university], course: params[:course]
         })
         @university_id = @university.id
    else
     @university = University.find_by({
       university: params[:university], course: params[:course]
         })
    @university_id = @university.id
    end
    @user.update_columns(
    name: params[:name],
    university_id: @university_id,
    grade: params[:grade],
    sex: params[:sex],
    mail: params[:mail], 
    line_id: params[:line_id]
    # password: params[:password],
    # password_confirmation: params[:password_confirmation]
    )
    redirect '/'
end


#-----------------投稿----------------------

get '/search_lesson/:id' do 
    ulesson_id = params[:id]
    user = User.find(session[:user])
        reviews = ''
        # unless user.nil?
            lesson_reviews = Review.where({ lesson_id: ulesson_id}).all
            lesson_reviews.each do |review|
                reviews << '<div class="cardborder card">'
                reviews << '<div class="card-img-top">'
                unless review.img.empty?
                    reviews << '<img src="' + review.img.to_s + '" class="card-img-top" height="150">'
                end
                reviews << '</div>'
                reviews << '<div class="card-body">'
                reviews << '<p class="card-title">' + review.title.to_s + '</p>'
                reviews << '<p class="card-con">' + review.body.to_s + '</p>'
                reviews << '<p>ポイント：' + review.point.to_s + 'P<br>投稿者：'+ User.find(review.user_id).name + '</p>'
                #reviews << '<p>作者：' + User.find(review.user_id).name + '</p>'
                reviews << '</div>'
                
                reviews << '<div class="card-footer">'
                if user.id == review.user_id
                   reviews << '<form action="/delete/' + review.id.to_s + '" method="post"><input type="submit" value="削除" class="btn-outline-secondary btn-sm"></form>'
                else
                    if User.find(session[:user]).point <= 0
                        reviews << '<form action="/request/' + review.id.to_s + '" method="post"><input type="submit" value="ポイントが足りません" class="btn btn-warning btn-sm" disabled="disabled"></form>'
                    else    
                        if review.request == 0 
                             reviews << '<form action="/request/' + review.id.to_s + '" method="post"><input type="submit" value="リクエストを送る" class="btn btn-warning btn-sm"></form>'
                        else
                             reviews << '<form action="/request/' + review.id.to_s + '" method="post"><input type="submit" value="交渉中" class="btn btn-warning btn-sm" disabled="disabled"></form>'
                        end
                    end    
                end
                reviews << '</div>'
                reviews << '</div>'
            end
        # else
        #     reviews << 'user nil'
        # end
        return reviews
end


post '/new' do
    @users = User.all
    @user = @users.find(session[:user])
    
    if  Lesson.find_by({university_id: @user.university_id, lesson: params[:lesson]}) == nil
       @lesson = Lesson.create({
       university_id: @user.university_id,
       lesson: params[:lesson]
        })
    else
     @lesson = Lesson.find_by({
       university_id: @user.university_id, lesson: params[:lesson]
         })
    end
   #@lesson = Lesson.create({
   #   university_id: @user.university_id,
   #   lesson: params[:lesson]
   #})
    Review.create({
        user_id: @user.id,
        lesson_id: @lesson.id,
        university_id: @user.university_id,
        title: params[:title],
        body: params[:body],
        point: params[:point],
        img: ""
    })
    
    if params[:img]
        image_upload(params[:img])
    end
    
    redirect '/'
end

post '/delete/:id' do
    Review.find(params[:id]).destroy
    redirect '/'
end

    
post '/revedit/:id' do
    @review = Review.find(params[:id])
    if  University.find_by({university: params[:university], course: params[:course]}) == nil
        @university = University.create({
       university: params[:university], course: params[:course]
         })
         @university_id = @university.id
    else
     @university = University.find_by({
       university: params[:university], course: params[:course]
         })
    @university_id = @university.id
    end
    
    
    @review.update_columns(
    title: params[:title],
    body: params[:body],
    point: params[:point],
    img: ""
    )
    
    if params[:img]
        image_upload(params[:img])
    end
    redirect '/'
end  

post '/request/:id' do
    @review = Review.find(params[:id])
    @user = User.find(session[:user])
    
    @review.update({
        request: 1,
        request_id: @user.id
    })
    erb :request
end

post '/request-done/:id' do
    user = User.find(session[:user]) #売った人
    review = Review.find(params[:id])
    review_user = User.find(review.request_id) #買う人
    
    user.update_columns(
        point: user.point + review.point
    )
    
    review_user.update_columns(
        point: review_user.point - review.point
    )
    
    Review.find(review.id).destroy
    
    redirect '/'
end

post '/request-none/:id' do
    @review = Review.find(params[:id])

    @review.update({
        request: 0
    })
    
    redirect '/'
end