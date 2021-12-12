import React from 'react';
import { useNavigate } from "react-router-dom";
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import { Button, CardActionArea, CardActions } from '@mui/material';
import { Grid } from '@mui/material';
 
const ProjectList = ({toDoList}) => {

    const navigate = useNavigate();

    const routeChange = (id) =>{ 
      let path = `project/` + id ; 
      navigate(path);
    }

   return (
       <div>
           <Grid container spacing={2}>
           {toDoList.map(todo => {
               return (
                <Grid item xs={3}>
                <Card sx={{ maxWidth: 345 }}>
                <CardActionArea>
                  {/* <CardMedia
                    component="img"
                    height="140"
                    image="/home/muskan/buildIt/my-app/public/logo192.png"
                    alt="green iguana"
                  /> */}
                  <CardContent>
                    <Typography gutterBottom variant="h5" component="div">
                      Project {todo.id}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {todo.task}
                    </Typography>
                  </CardContent>
                </CardActionArea>
                <CardActions>
                  <Button size="small" color="primary" onClick={() => routeChange(todo.id)}>
                    Open
                  </Button>
                </CardActions>
              </Card>
              </Grid>
               )
           })}
           </Grid>
       </div>
   );
};
 
export default ProjectList;